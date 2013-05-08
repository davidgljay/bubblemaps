class PostTag < ActiveRecord::Base
  attr_accessible :post_id, :tag_id

  belongs_to :post, :class_name => "Post"
  belongs_to :tag, :class_name => "Tag"
end
