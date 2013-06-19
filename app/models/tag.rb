class Tag < ActiveRecord::Base
  attr_accessible :heat1, :heat2, :name, :postcount, :source

  has_many :post_tags, :foreign_key => "tag_id", :dependent => :destroy
  has_many :posts, :through => :post_tags, :source => :post

  def self.topx(num = 20, tag = nil, tag2 = nil)
    if tag.nil?
      Tag.all.map{|t| {:label => t.name, :volume => t.postcount}}.sort{|x,y| y[:volume]<=>x[:volume]}.first(num)
    else
      posts = Tag.find_by_name(tag).posts.map{|p| p.text}
      posts.select!{|p| p.include?(tag2)} unless tag2.nil?
      related = posts.flatten
      related_frequency = []
      (related.uniq-[tag]-[tag2]).each do |r|
        related_frequency << {:label => r, :volume => related.count(r)}
      end
      related_frequency.sort{|x,y| y[1]<=>x[1]}.first(num)
    end
  end

  def buzz
    first = Date.new(2013,01,04)
    last = Date.new(2013,04,07)
    med = posts.map{|p| p.date}.sort{|x,y| y<=>x }[posts.length/2]
    self.heat1 = 100 - (med.to_date-last).to_f/(first-last).to_f * 100
    self.save
    heat1
  end

  def links
    posts = self.posts.map{|p| p.text}
    related = posts.flatten
    self.heat2 = (related.uniq-[self.name]).count
    self.save
  end


  def self.set_all_postcounts
    Tag.find_each{|t| t.set_postcount}
  end

  def self.set_variables
    ActiveRecord::Base.transaction do
      Tag.where("postcount IS NULL").find_each do |t|
        t.set_postcount
      end
      Tag.where("heat1 IS NULL").find_each do |t|
        t.buzz
      end
      Tag.where("heat2 IS NULL").find_each do |t|
        t.links
      end
    end
  end

  def set_postcount
    self.postcount = posts.count
    self.save
  end

end
