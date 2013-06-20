class Post < ActiveRecord::Base
  require 'csv'
  require 'open-uri'
  require 'nokogiri'
  attr_accessible :source,:date, :heat1, :heat2, :text, :authorhash

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
      CSV.foreach(open(url), headers: true) do |row|
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
    xpaths = {:item => '//item', :text => 'title', :date => 'pubDate', :author => 'creator', :tags => 'category'}
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
      tags = headline.xpath(xpaths[:tags]).map {|t| t.text}

      headlines << {:text => text, :date => date, :authorhash => {:name => author}, :tags => tags}
    end
    posts = []
    ActiveRecord::Base.transaction do
      headlines.each do |headline|
        if headline[:date] > mostrecent
          p = Post.create(:date => headline[:date], :text => headline[:text], :source => source, :authorhash => headline[:authorhash])
          posts << p
          headline[:tags].each do |t|
            tag = Tag.where("name = #{ActiveRecord::Base::sanitize(t)} AND source = '#{source}'").first_or_create(:name => t, :source => source)
            p.tags << tag
          end
        end
      end
    end
    #self.bulk_extract_tags(posts)
    Tag.set_variables(source)
    posts.count
  end

  #Import tweets from twitter based on a search term

  def self.twitter_import(term)
    results = Twitter.search(term, :lang => 'en', :count => 100).results
    source = "twitter-#{term}"
    mostrecent = mostrecent(source)
    posts = []
    ActiveRecord::Base.transaction do
      results.each do |tweet|
        if tweet.created_at > mostrecent
          author = tweet.user
          posts << Post.create(:date => tweet.created_at, :text => tweet.text, :source => source, :authorhash => {:name => author.name, :screen_name => author.screen_name, :location => author.location, :description => author.description, :profile_image => author.profile_image_url})
        end
      end
    end
    self.bulk_extract_tags(posts)
    Tag.set_variables(source)
    posts.count
  end

  #Extract tags from a post
  #Common english words are ignored, otherwise every word is treated as a tag
  #After tags are extracted, Tag.set_variables is run to see if there are tags which need to have their postcounts and heat updated.

  def self.bulk_extract_tags(posts)
    ActiveRecord::Base.transaction do
      posts.each do |p|
        p.extract_tags
      end
    end

  end



  def extract_tags
    if text.class == Array
      text.each do |t|
        tag = Tag.find_or_create_by_name(t.downcase)
        self.tags << tag unless self.tags.include?(tag)
        tag.source = self.source
        tag.save
      end
    elsif text.class == String
      text.gsub(/[^0-9a-z\- ]/i, '').split(' ').each do |t|
        unless ignore.include?(t.downcase)
          tag = Tag.where("name = '#{t}'").first_or_create(:name => t, :source => self.source)
          self.tags = (self.tags +  [tag]).uniq
        end
      end
    end
    self.save
    self.tags
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

end
