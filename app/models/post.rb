class Post < ActiveRecord::Base
  require 'csv'
  require 'open-uri'
  require 'upsert/active_record_upsert'
  require 'nokogiri'
  attr_accessible :source,:date, :heat1, :heat2, :text

  serialize :text

  has_many :post_tags, :foreign_key => "post_id", :dependent => :destroy
  has_many :tags, :through => :post_tags, :source => :tag


  def self.file_import(file)
    self.csv_import(file.url)
  end

  def self.csv_import(url, source)
    mostrecent = Post.where("source = '#{source}'").order("date DESC").first.date
    posts = []
    ActiveRecord::Base.transaction do
      CSV.foreach(open(url), headers: true) do |row|
        if row[1] > mostrecent
          posts << Post.create(:date => row[1], :text => row[2][1..-2].split('><').to_a, :source => source)
        end
      end
    end

    self.extract_recent_tags(posts)
    GC.start
  end

  def self.nyt_import(url = 'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml')
    headlines = []
    if Post.where("source = 'NYT'").empty?
      mostrecent = Date.new(1500,1,1)
    else
      mostrecent = Post.where("source = 'NYT'").order("date DESC").first.date
    end
    data = Nokogiri::XML(open(url).read.strip)
    data.xpath('//item').each do |headline|
      title = headline.xpath('title').children.text
      date = headline.xpath('pubDate').children.text.to_datetime
      headlines << {:title => title, :date => date}
    end
    posts = []
    ActiveRecord::Base.transaction do
      headlines.each do |headline|
        if headline[:date] > mostrecent
          posts << Post.create(:date => headline[:date], :text => headline[:title], :source => 'NYT')
        end
      end
    end
    self.extract_recent_tags(posts)
    GC.start
  end



  def self.extract_recent_tags(posts)
    ActiveRecord::Base.transaction do
      posts.each do |p|
        p.extract_tags
      end
    Tag.set_variables
    end

  end

  def extract_tags
    if text.class == Array
      text.each do |t|
        tag = Tag.find_or_create_by_name(t)
        self.tags << tag unless self.tags.include?(tag)
        tag.source = self.source
        tag.save
      end
    elsif text.class == String
      ignore = ["the", "be", "and", "of", "a", "in", "to", "have", "to", "it", "I", "that", "for", "you", "he", "with", "on", "do", "say", "this", "they", "at", "but", "we", "his", "from", "that", "not", "n't", "n't", "by", "she", "or", "as", "what", "go", "their", "can", "who", "get", "if", "would", "her", "all", "my", "make", "about", "know", "will", "as", "up", "one", "time", "there", "year", "so", "think", "when", "which", "them", "some", "me", "people", "take", "out", "into", "just", "see", "him", "your", "come", "could", "now", "than", "like", "other", "how", "then", "its", "our", "two", "more", "these", "want", "way", "look", "first", "also", "new", "because", "day", "more", "use", "no", "man", "find", "here", "thing", "give", "many"]
      text.gsub(/[^0-9a-z\- ']/i, '').split(' ').each do |t|
        unless ignore.include?(t.downcase)
          tag = Tag.where("name = '#{t}'").first_or_create(:name => t, :source => self.source)
          self.tags = (self.tags +  [tag]).uniq
        end
      end
    end
    self.save
    self.tags
  end

  def fix_text
    if text.class == String
      self.text = text[1..-2].split('><').to_a
      self.save
    end
  end

end
