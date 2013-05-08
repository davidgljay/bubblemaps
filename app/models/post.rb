class Post < ActiveRecord::Base
  require 'csv'
  attr_accessible :date, :heat1, :heat2, :text
  serialize :text

  has_many :post_tags, :foreign_key => "post_id", :dependent => :destroy
  has_many :tags, :through => :post_tags, :source => :tag

  def self.import(file)
    array = []
    CSV.foreach(file.path, headers: true) do |row|
      p = Post.new(:date => row[1], :text => row[2][1..-2].split('><').to_a)
      array << p
      p.save
    end
    array.each do |p|
      p.extract_tags
    end
  end

  def extract_tags
    text.each do |t|
      tag = Tag.find_or_create_by_name(t)
      self.tags << tag unless self.tags.include?(tag)
    end
  end

  def fix_text
    if text.class == String
      self.text = text[1..-2].split('><').to_a
      self.save
    end
  end

end
