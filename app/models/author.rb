class Author < ActiveRecord::Base
  attr_accessible :description, :location, :name, :profile_image, :screen_name
end
