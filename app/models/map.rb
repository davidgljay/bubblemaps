class Map < ActiveRecord::Base
  attr_accessible :maphash, :name
  serialize :maphash

  def sunburst_map
    self.maphash = Tag.topx(20).map
      {
          :name => t[:label],
      :children =>
      Tag.topx(20,t[0]).map{|t2|
        {
            :name => t2[:label],
        :size => t2[:volume]
        }
      }
      }
    self.save
  end

  def topx_map
    self.maphash = Tag.topx(20)
    self.save
  end

  def circle_map(source)
    self.maphash = Tag.where("'source' == '#{source}'").order("'postcount' DESC").first(1000).map{|t|
    {
        :name => t.name,
        :size => t.postcount,
        :buzz => t.heat1,
        :links => t.heat2,
       # :related => Tag.topx(200, t.name)
    }
    }
    self.save

  end
end
