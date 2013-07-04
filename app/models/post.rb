class Post < ActiveRecord::Base
  require 'csv'
  require 'open-uri'
  require 'nokogiri'
  attr_accessible :source,:date, :heat1, :heat2, :text, :authorhash, :url, :description

  serialize :text
  serialize :authorhash

  has_many :post_tags, :foreign_key => "post_id", :dependent => :destroy
  has_many :tags, :through => :post_tags, :source => :tag

  #Accepts an uploaded CSV file

  def self.file_import(file)
    self.csv_import(file.url)
  end

  #Accepts the URL of a CSV File of form:
  # Date, Text (with tags in the form <tag><tag>)
  # This is built to accept data from StackExchange
  def self.csv_import(url, source)
    mostrecent = mostrecent(source)
    posts = []
    ActiveRecord::Base.transaction do
      CSV.new(open(url).read, :headers => true).each do |row|
        if row[1].to_datetime > mostrecent
          posts << Post.create(:date => row[1], :text => row[2][1..-2].split('><').to_a, :source => source)
        end
      end
    end

    self.bulk_extract_tags(posts)
    posts.count
  end

  #Import front page headlines form the New York Times. This process will be moved to a map.
  def self.nyt_import
    url = 'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml'
    source = 'NYT'
    xpaths = {:item => '//item', :text => 'title', :date => 'pubDate', :author => 'creator', :tags => 'category', :url => 'link'}
    self.xml_import(url, source, xpaths)
  end

  #Import posts from an arbitrary xml file.
  # URL is the location of the file
  # Source is a string describing the source, it is used as a unique identifier for data from that source
  # xpaths is a hash describing the xpath locators of the text, date, and author information

  def self.xml_import(url, source, xpaths)
    headlines = []
    mostrecent = mostrecent(source)
    data = Nokogiri::XML(open(url).read.strip).remove_namespaces!
    data.xpath(xpaths[:item]).each do |headline|
      text = headline.xpath(xpaths[:text]).text
      date = headline.xpath(xpaths[:date]).text.to_datetime
      author = headline.xpath(xpaths[:author]).text
      postUrl = headline.xpath(xpaths[:url]).text
      tags = headline.xpath(xpaths[:tags]).map {|t| t.text}

      headlines << {:text => text, :date => date, :authorhash => {:name => author}, :tags => tags, :url => postUrl}
    end
    posts = []
    tags = []
    ActiveRecord::Base.transaction do
      headlines.each do |headline|
        if headline[:date] > mostrecent
          p = Post.create(:date => headline[:date], :text => headline[:text], :source => source, :authorhash => headline[:authorhash], :url => headline[:url])
          posts << p
          headline[:tags].each do |t|
            tag = Tag.where("name = #{ActiveRecord::Base::sanitize(t)} AND source = '#{source}'").first_or_create(:name => t, :source => source)
            p.tags << tag
            tags << tag
          end
        end
      end
    end
    Tag.bulk_set_variables(tags)
    posts.count
  end

  #Import tweets from twitter based on a search term

  def self.twitter_import(source, pages = 1)
    results = []
    term = source.first(8) == 'twitter-' ? source[8..-1] : source
    results << Twitter.search(term, :lang => 'en', :count => 100).results
    maxid = results.flatten.last.id
    pages.times do
      results << Twitter.search(term, :lang => 'en', :count => 100, :max_id => maxid - 1).results
      maxid = results.flatten.last.id
    end
    results.flatten!

    source = "twitter-#{term}"
    mostrecent = mostrecent(source)
    posts = []
    ActiveRecord::Base.transaction do
      results.each do |tweet|
        if tweet.created_at > mostrecent
          author = tweet.user
          posts << Post.create(:date => tweet.created_at, :text => tweet.text, :source => source, :authorhash => {:name => author.name, :screen_name => author.screen_name, :location => author.location, :description => author.description, :profile_image => author.profile_image_url, :url => author.url})
        end
      end
    end
    self.bulk_extract_tags(posts)
    posts.count
  end


  #Import tags from pubmed

  def self.pubmed_import(source, numresults = 5000)
    term = source.first(7) == 'pubmed-' ? source[7..-1] : source
    source = "pubmed-#{term}"
    mostrecent = mostrecent(source)
    cleanterm = Rack::Utils.escape(term)
    #Get a list of pubmed IDs for the search terms
    url1 = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=' + cleanterm + '&retmax=' + numresults.to_s
    xml1 = Nokogiri::XML(open(url1))
    if @error
      @error
    else
      pids = xml1.xpath("//IdList/Id").map{|p| p.text}
      articles = []
      pids.in_groups_of(200) do |pid_batch|
        url2 = pids.empty? ? 'http://www.google.com' : 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=' + pid_batch * ',' + '&retmode=xml&rettype=abstract'
        data = Nokogiri::XML(open(url2).read.strip).remove_namespaces!
        if @error
          @error
        else
          articles << data.xpath('//PubmedArticle')
        end
      end
      # Get info for those papers from pubmed, no way to avoid the double trip.


      papers = []
      posts = []
      tags = []

      articles.flatten.each do |article|
        pmid = article.xpath('MedlineCitation/PMID').text
        mesh = article.xpath('MedlineCitation/MeshHeadingList/MeshHeading/DescriptorName').map{|c| c.text}
        keywords =  article.xpath('MedlineCitation/KeywordList/Keyword').map{|c| c.text}
        terms = mesh + keywords
        title = article.xpath('MedlineCitation/Article/ArticleTitle').text
        abstract = article.xpath('MedlineCitation/Article/Abstract/AbstractText').text

        # Capture the publication date
        day = article.xpath('MedlineCitation/DateCreated/Day').text.to_i
        month = article.xpath('MedlineCitation/DateCreated/Month').text.to_i
        year = article.xpath('MedlineCitation/DateCreated/Year').text.to_i

        if year
          begin
            pubdate = Time.local(year, month, day)
          rescue
            pubdate = Time.local(year)
          end
        else
          pubdate = nil
        end

        #Capture the list of authors
        authors = []
        authorlist = article.xpath('MedlineCitation/Article/AuthorList')
        authorlist.xpath('Author').each do |a|
          firstname = a.xpath('ForeName').text
          lastname = a.xpath('LastName').text
          authors << {:firstname => firstname, :lastname => lastname, :name => lastname + ', ' + firstname }
        end
        if terms
        papers << {:pubmed_id => pmid, :text => title, :terms => terms, :date => pubdate, :description => abstract, :authorhash => authors}
        end
      end
      #Create a post for each paper

      ActiveRecord::Base.transaction do
        papers.each do |p|
          if p[:date] > mostrecent && !p[:terms].empty? &&  p[:date]
            post = Post.create(:text => p[:text], :date => p[:date], :authorhash => p[:authors], :url => "http://www.ncbi.nlm.nih.gov/pubmed/#{p[:pubmed_id]}", :description => p[:description], :source => source)
            posts << post
            p[:terms].each do |t|
              tag = Tag.where("name = #{ActiveRecord::Base::sanitize(t)} AND source = '#{source}'").first_or_create(:name => t, :source => source)
              post.tags << tag
              tags << tag

            end
          end
        end
      end

      Tag.bulk_set_variables(tags)
      posts.count
    end
  end


  def display_authors
    if authorhash.count > 3
      display_authors = authorhash[0][:lastname] + ', ' + authorhash[-1][:lastname] + ", et al."
    else
      display_authors = authorhash.map{|a| a[:lastname]} * ', ' + '.'
    end
    display_authors
  end



  def scrub(string) #getting wierd intermittent errors from some pubmed into, this should address them.
    string ||= ''
    string.gsub(/['\u2029''\u2028']/,'')
  end


  #Extract tags from a post
  #Common english words are ignored, otherwise every word is treated as a tag
  #After tags are extracted, Tag.set_variables is run to see if there are tags which need to have their postcounts and heat updated.

  def self.bulk_extract_tags(posts)
    ActiveRecord::Base.transaction do
      tags_array = []
      posts.each do |p|
        tags_array << p.extract_tags
      end
    end
    Tag.bulk_set_variables(tags_array)
  end



  def extract_tags
    tags_array = []
    if text.class == Array
      text.each do |t|
        tag = Tag.find_or_create_by_name(t.downcase)
        self.tags << tag unless self.tags.include?(tag)
        tag.source = self.source
        tags_array << tag
      end
    elsif text.class == String
      text.gsub(/[^0-9a-z\- ]/i, '').split(' ').each do |t|
        unless ignore.include?(t.downcase)
          tag = Tag.where("name = '#{t}'").first_or_create(:name => t, :source => self.source)
          self.tags = (self.tags +  [tag]).uniq
          tags_array << tag
        end
      end
    end
    self.save
    tags_array
  end

  #Determine the most recent post for a given source
  #Used to avoid creating duplicate posts for the same source

  def self.mostrecent(source)
    if Post.where("source = '#{source}'").empty?
      Date.new(1500,1,1)
    else
      Post.where("source = '#{source}'").order("date DESC").first.date
    end
  end

  #List of words to ignore

  def ignore
    ["the", "be", "is", "and", "of", "a", "in", "to", "have", "to", "it", "i", "that", "for", "you", "he", "with", "on", "do", "say", "this", "they", "at", "but", "we", "his", "from", "that", "not", "n't", "n't", "by", "she", "or", "as", "what", "go", "their", "can", "who", "get", "if", "would", "her", "all", "my", "make", "about", "know", "will", "as", "up", "one", "time", "there", "year", "so", "think", "when", "which", "them", "some", "me", "people", "take", "out", "into", "just", "see", "him", "your", "come", "could", "now", "than", "like", "other", "how", "then", "its", "our", "two", "more", "these", "want", "way", "look", "first", "also", "new", "because", "day", "more", "use", "no", "man", "find", "here", "thing", "give", "many", "big", "says", "group", "-", "was", "always", "doing", "Im", "rt", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
  end

  def source_type
    self.source.split('-').first
  end

  def self.fromsource(source)
    Post.where("source = '#{source}'")
  end
end
