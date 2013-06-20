class MapsController < ApplicationController
  def show
    @map = Map.find(params[:id])
    @title = @map.display_name
    @select = @map.name
      respond_to do |format|
      format.json {render :json => @map.maphash.to_json}
      format.html
    end
  end
end
