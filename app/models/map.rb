class Map < ActiveRecord::Base
  attr_accessible :maphash, :name
  serialize :maphash
  serialize :taghash

  validate :name, uniqueness: true, presence: true

 def to_csv(include = self.posts.count)
   CSV.generate do |csv|
     csv << ["Post Date", "Author", "Text"]
     posts.each do |post|
       csv << [post.date, post.authorhash[:screen_name], post.text]
     end
   end
 end

  def circle_map(source = self.source ,include = 200, threshold = 2)
    posts = Post.where("source = '#{source}'")
    self.taghash = Post.bulk_extract_tags(posts)
    map = self.taghash.map{|t|
      {
          :name => t[0],
          :size => t[1][:posts].count,
          :buzz => median_date(t[1][:postdates]).to_i,
          #:links => t.heat2,
          # :related => Tag.topx(200, t.name)
      }
    }
    self.maphash = map.sort{|x,y| y[:size] <=> x[:size]}.first(include).select{|t| t[:size] >= threshold && t[:name].downcase != self.source_word.downcase}
  end

  def median_date(postdates)
    postdates.sort{|x,y| y<=>x }[postdates.count/2]
  end

  def self.nyt_map
    nyt = Map.find_or_create_by_name('NYT')
    nyt.update_map
    nyt.update_me = true

    nyt.circle_map(source, 200, 2)
    nyt.save

  end

  def self.twitter_map(term)
    source = "twitter-#{term}"
    map = Map.find_or_create_by_name(source)
    Post.twitter_import(source, 5)
    map.update_me = false
    map.display_name = "#{term} on Twitter"
    map.urlname = 'twitter-' + map.name.gsub(/[^0-9a-z\- ]/i, '').split('-')[1]
    map.circle_map(source, 200, 2)
    map.save
    map
  end

  def self.pubmed_map(term)
   source = "pubmed-#{term}"
   map = Map.find_or_create_by_name(source)
   Post.pubmed_import(source)
   map.update_me = false
   map.display_name = "#{term} on PubMed"
   map.urlname = 'pubmed-' + map.name.gsub(/[^0-9a-z\- ]/i, '').split('-')[1]
   map.circle_map(source, 200, 2)
   map.save
   map
  end

  def update_map
    if self.source_type == 'NYT'
      url = 'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml'
      xpaths = {:item => '//item', :text => 'title', :date => 'pubDate', :author => 'creator', :tags => 'category', :url => 'link'}
      Post.xml_import(url, self.source, xpaths)
    elsif source_type == 'twitter'
      Post.twitter_import(source)
    elsif source_type == 'pubmed'
      Post.pubmed_import(source)
    end
    self.circle_map(source, 200, 2)
    self.save
  end

  def self.update_all_maps
    Map.all.each do |m|
      m.update_map if m.update_me
    end
  end

  def source
    self.name
  end

  def source_type
    self.source.split('-').first
  end

  def source_word
    self.source.split('-')[1]
  end

  def posts
    Post.fromsource(self.name)
  end
end
