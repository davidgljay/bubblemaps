class TagsController < ApplicationController
  def list_posts
    @map = Map.find_by_urlname(params[:source])
    @postids = @map.taghash[params[:name]][:posts].reverse.first(10)
    @posts = @postids.map{|p| Post.find(p)}
    @source_type = @map.source_type
    respond_to do |format|
      format.html
      format.js
    end
  end
end
