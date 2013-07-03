class Tag < ActiveRecord::Base
  attr_accessible :heat1, :heat2, :name, :postcount, :source, :post_id

  has_many :post_tags, :foreign_key => "tag_id", :dependent => :destroy
  has_many :posts, :through => :post_tags, :source => :post, :order => 'date DESC'


  class << self
    def topx(num = 20, tag = nil, tag2 = nil)
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



    def set_postcounts(source, threshold = 2)
      ActiveRecord::Base.transaction do
        Tag.where("source = '#{source}'").find_each{|t| t.set_postcount}
        if Tag.where("source = '#{source}'").count > 1000
          Tag.where("source = '#{source}' AND postcount < #{threshold}").find_each{|t| t.destroy}
        end
      end
    end

  end

  def set_variables
    self.set_postcount
    self.set_buzz
    self.set_links
    self.save
  end

  def self.bulk_set_variables(tags)
    ActiveRecord::Base.transaction do
      tags.flatten.uniq.each {|t| t.set_variables}
    end
  end

  def set_postcount
    self.postcount = posts.count
  end

  def set_buzz
    unless posts.empty?
      first = Post.where("source = '#{source}'").order("date ASC").first.date
      last = Post.where("source = '#{source}'").order("date ASC").last.date
      med = self.posts.map{|p| p.date}.sort{|x,y| y<=>x }[self.posts.count/2]
      self.heat1 = 1000 - (med.to_time-last).to_f/(first-last).to_f * 1000
    end
  end


  def set_links
    unless posts.empty?
      posts = self.posts.map{|p| p.tags}
      related = posts.flatten.uniq
      self.heat2 = (related-[self.name]).count
    end
  end

  def self.clean_ignore
    ignore = Post.new.ignore
    Tag.find_each do |t|
      if ignore.include?(t.name.downcase)
        t.destroy
      end
    end
  end

  def source_type
    self.source.split('-').first
  end

  def self.fromsource(source)
    Tag.where("source = '#{source}'")
  end
end
