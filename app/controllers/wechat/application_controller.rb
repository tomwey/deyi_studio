require 'rest-client'
class Wechat::ApplicationController < ActionController::Base
  layout 'wechat'
  protect_from_forgery with: :null_session
  
  # 验证请求是否来自于微信服务器
  before_filter :check_wechat_legality
  
  private
  def check_wechat_legality
    render(text: "Forbidden", status: 403) unless Wechat::Base.check_wechat_legality(params[:timestamp],params[:nonce], params[:signature])
  end
end