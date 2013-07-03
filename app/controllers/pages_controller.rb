class PagesController < ApplicationController
  def home
    @title = 'See what all the buzz is about'
    @map = Map.find_by_name('NYT')
    @posts = Post.where("source = '#{@map.name}'").first(10)
    @source_type = @map.source_type
    @select = 'home'
  end
end
