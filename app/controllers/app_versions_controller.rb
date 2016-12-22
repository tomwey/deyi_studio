class AppVersionsController < ApplicationController

  def info    
    @app = AppVersion.opened.where('lower(os) = ? and mode = ? and version = ?', params[:os].downcase, params[:m], params[:bv]).first
    
    if @app.blank?
      render template: "/errors/404", format: [:html],
             handler: [:erb], status: status, layout: 'application'
      return
    end
    
  end
    
end