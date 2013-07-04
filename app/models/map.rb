class Map < ActiveRecord::Base
  attr_accessible :maphash, :name
  serialize :maphash

  validate :name, uniqueness: true, presence: true

  #def sunburst_map
  #  self.maphash = Tag.topx(20).map
  #  {
  #      :name => t[:label],
  #      :children =>
  #          Tag.topx(20,t[0]).map{|t2|
  #            {
  #                :name => t2[:label],
  #                :size => t2[:volume]
  #            }
  #          }
  #  }
  #  self.save
  #end
  #
  #def topx_map
  #  self.maphash = Tag.topx(20)
  #  self.save
  #end

  def circle_map(source = self.source ,include = 200, threshold = 2)
    self.maphash = Tag.where("source = '#{source}' AND postcount > '#{threshold}'").order("postcount DESC").first(include).map{|t|
      {
          :name => t.name,
          :size => t.postcount,
          :buzz => t.heat1,
          :links => t.heat2,
          # :related => Tag.topx(200, t.name)
      }
    }
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
    Post.twitter_import(source, 24)
    map.update_me = true
    map.circle_map(source, 200, 2)
    map.save
  end

  def self.pubmed_map(term)
   source = "pubmed-#{term}"
   map = Map.find_or_create_by_name(source)
   Post.pubmed_import(source)
   map.update_me = false
   map.circle_map(source, 200, 2)
   map.save
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

end
