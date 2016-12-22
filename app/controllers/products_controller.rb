class ProductsController < ApplicationController

  def show
    @product = Product.find_by(sku: params[:id])
  end
    
end