class Wechat::HomeController < Wechat::ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:welcome]
  
  def welcome
    if wechat_xml.event
      if wechat_xml.event.downcase == 'click'
        handle_click
      elsif wechat_xml.event.downcase == 'subscribe'
        handle_subscribe
      elsif wechat_xml.event.downcase == 'unsubscribe'
        handle_unsubscribe
      else
        handle_kefu
      end
    else
      handle_kefu
    end
  end
  
  def portal
    render text: params[:echostr]
  end
  
  private
  def handle_click
    @msg_type = 'text'
    if wechat_xml.event_key == 'menu_bind'
      generate_wechat_auth
    elsif wechat_xml.event_key == 'menu_active'
      active_wechat_auth
    end
  end
  
  def generate_wechat_auth
    code = WeixinAuthCode.where(openid: wechat_xml.from_user).first_or_create
    if code.user_id.blank?
      if code.expired?
        code.update_auth_code!
      end
      
      @content = "您的微信验证码为: #{code.code}\n*验证码有效期为三分钟。\n\n请回到#{CommonConfig.app_name}的微信绑定页面，输入该验证码进行绑定。"
      
    else
      # 已经绑定了公众号，显示用户的信息
      user = code.user
      @content = "ID: #{user.uid}\n余额: #{user.balance}益豆\n----------------\n今日收益: #{user.today_beans}益豆"
    end
  end
  
  def active_wechat_auth
    code = WeixinAuthCode.where(openid: wechat_xml.from_user).first
    if code.blank?
      @content = "请先点击绑定账号"
    else
      if code.user_id.blank?
        @content = "您未绑定#{CommonConfig.app_name}账号，无法激活提现。"
      else
        code.active!
        @content = "恭喜激活提现成功，您现在可以通过微信进行提现了。"
      end
    end
  end
  
  def handle_subscribe
    @msg_type = 'text'
    @content  = CommonConfig.welcome_wechat || '您好，欢迎关注得益WIFI！' 
  end
  
  def handle_unsubscribe
    code = WeixinAuthCode.where(openid: wechat_xml.from_user).first
    if code
      code.unbind!
    end
  end
  
  def handle_kefu
    @msg_type = 'transfer_customer_service'
  end
  
end