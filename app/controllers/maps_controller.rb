class MapsController < ApplicationController
  def show
    @map = Map.find(params[:id])
    render :json => @map.maphash.to_json
  end
end
