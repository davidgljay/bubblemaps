class TagsController < ApplicationController
  def list_posts
    @map = Map.find_by_urlname(params[:source])
    @tag = Tag.where("name = '#{params[:name]}' AND source = '#{@map.source}'").first
    @posts = @tag.posts.first(40)
    @source_type = @tag.source_type
    respond_to do |format|
      format.html
      format.js
    end
  end
end
