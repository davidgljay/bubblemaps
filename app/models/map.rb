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

  def circle_map(source,include = 100, threshold = 4)
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
    nyt.update
  end

  def self.twitter_map(term)
    source = "twitter-#{term}"
    map = Map.find_or_create_by_name(source)
    map.update
  end

  def update_map
    if self.source_type == 'NYT'
      url = 'http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml'
      xpaths = {:item => '//item', :text => 'title', :date => 'pubDate', :author => 'creator', :tags => 'category', :url => 'link'}
      Post.xml_import(url, self.source, xpaths)
    elsif source_type == 'twitter'
      Post.twitter_import(source)
    end
    self.circle_map(source, 100, 2)
    self.save
  end

  def source
    self.name
  end

  def source_type
    self.source.split('-').first
  end

end
