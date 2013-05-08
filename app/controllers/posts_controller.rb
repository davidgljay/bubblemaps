class PostsController < ApplicationController
  def import
    Post.import(params[:file])
    redirect_to root_url, notice: "Products imported."
  end
end
