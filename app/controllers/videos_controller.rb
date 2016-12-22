class VideosController < ApplicationController

  def index
    
  end
  
  def create
    item = {}
    item[:success] = true
    item[:file] = params[:key].split('/').last
    render json: item
  end
    
end