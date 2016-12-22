class Shoutu::InviteController < ApplicationController
  def index
    uid = params[:uid]
    
    if uid.blank?
      render_optional_error_file(403)
      return
    end
    
    @user = User.find_by(uid: uid)
    if @user.blank?
      render_optional_error_file(404)
      return
    end
    
    @play_days = ((Time.zone.now - @user.created_at) / 1.day).to_i + 1
    
    @users = User.select(:nickname, :uid, :mobile, :avatar, :bean).where('bean > ?', 0).order('bean desc').limit(3)
    
    @earn_logs = EarnLog.includes(:user).where(earnable_type: ['Channel', 'AppTask']).order('id desc').limit(10)
  end
  
  def render_optional_error_file(status_code)
    status = status_code.to_s
    fname = %w(404 403 422 500).include?(status) ? status : 'unknown'
    render template: "/errors/#{fname}", format: [:html],
           handler: [:erb], status: status, layout: 'application'
  end
  
  def info
    uid = params[:uid]
    
    if uid.blank?
      render_optional_error_file(403)
      return
    end
    
    user = User.find_by(uid: uid)
    if user.blank?
      render_optional_error_file(404)
      return
    end
    
    @tip_header = CommonConfig.invite_share_earn_tip || ''
    
    slug = CommonConfig.invite_help_page_slug_name
    @tip_body   = Page.find_by(slug: slug).try(:body)
    
    # 累计学徒奖励
    @total_share_earn = InviteEarn.where(user_id: user.id).sum(:earn)
    
    # 徒弟数量
    @total_invited_users_count = user.invited_users.count
    
    # 今日徒弟数量
    @today_invited_users_count = Invite.where(inviter_id: user.id, created_at: Date.today.beginning_of_day..Date.today.end_of_day).count
    
    # 今日获得的奖励
    @today_total_share_earn = InviteEarn.where(user_id: user.id, created_at: Date.today.beginning_of_day..Date.today.end_of_day).sum(:earn)
     
  end
end