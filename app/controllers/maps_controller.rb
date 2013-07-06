class MapsController < ApplicationController
  def show
    @select = params[:id]
    @map = Map.find_by_urlname(@select)
    @posts = Post.where("source = '#{@map.source}'").first(10)
    @source_type = @map.source_type
    @title = @map.display_name

      respond_to do |format|
      format.json {render :json => @map.maphash.to_json}
      format.html
      format.csv {send_data @map.to_csv(2000)}
    end
  end
end
