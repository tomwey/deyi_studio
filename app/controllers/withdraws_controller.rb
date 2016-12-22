class WithdrawsController < ApplicationController
  
  before_filter :login_with_token
  
  def new
    if params[:type].blank?
      render template: "/errors/403", format: [:html],
             handler: [:erb], status: 403, layout: 'application'
      return
    end
    
    
    
  end
  
  def create
    
  end
  
  private
    def login_with_token
      @user = User.find_by(private_token: params[:token])
      if @user.blank?
        render template: "/errors/403", format: [:html],
               handler: [:erb], status: 403, layout: 'application'
        return false
      end
    end
    
end