class Callback::AppCallbackController < ApplicationController
  
  # 有米
  def youmi    
    order = params[:order]
    
    # 开发者appid
    app   = params[:app]
    
    key = app + order
    # 由于网络原因重复回调了多次相同的订单数据
    if $redis.get(key).present?
      # 返回403
      render text: 'failed', status: :forbidden
      return
    end
    
    $redis.set(key, '1')
    
    # 应用名或者广告名称
    ad    = params[:ad]
    
    # 用户ID
    user_id = params[:user]
    
    # 用户可赚取的积分
    points = params[:points]
    
    chn = ( params[:chn] || 0 ).to_s
    
    str = "#{SiteConfig.youmi_dev_secret || 'fa10ee82354768dc'}||#{order}||#{app}||#{user_id}||#{chn}||#{ad}||#{points}"
    
    signature = Digest::MD5.hexdigest(str)[12, 8]
    # 参数签名结果
    sig = params[:sig]
    if signature == sig
      # 参数校验正确
      count = ChannelCallbackLog.where(chn_id: app, order_id: order, uid: user_id).count
      if count == 0
        # 保存记录
        cb_params = []
        params.each do |k,v|
          cb_params << "#{k}=#{v}"
        end
        ChannelCallbackLog.create!(chn_id: app, order_id: order, uid: user_id, ad_name: ad, earn: points, callback_params: cb_params, result: 'ok')
      end
    else
      # 校验失败
      puts '校验失败'
    end
    
    $redis.del(key)
    
    render text: 'ok'
  end
  
  # 趣米
  def qumi
    order = params[:order]
    
    # 开发者appid
    app   = params[:app]
    
    key = app + order
    # 由于网络原因重复回调了多次相同的订单数据
    if $redis.get(key).present?
      # 返回403
      render status: :forbidden
      return
    end
    
    $redis.set(key, '1')
    
    # 应用名或者广告名称
    ad    = params[:ad]
    
    # 用户ID
    user_id = params[:user]
    
    # 用户可赚取的积分
    points = params[:points]
    
    # str = SiteConfig.qumi_dev_secret || '' + '||' + order + '||' + app + '||' + ad + '||' + user_id + '||' + params[:device] + '||' + points.to_s + '||' + params[:time]
    str = "#{SiteConfig.qumi_dev_secret || ''}||#{order}||#{app}||#{ad}||#{user_id}||#{params[:device]}||#{points}||#{params[:time]}"
    
    signature = Digest::MD5.hexdigest(str)[8, 16]
    
    # 参数签名结果
    sig = params[:sig]
    if signature == sig
      # 参数校验正确
      count = ChannelCallbackLog.where(chn_id: app, order_id: order, uid: user_id).count
      if count == 0
        # 保存记录
        cb_params = []
        params.each do |k,v|
          cb_params << "#{k}=#{v}"
        end
        ChannelCallbackLog.create!(chn_id: app, order_id: order, uid: user_id, ad_name: ad, earn: points, callback_params: cb_params, result: 'ok')
      end
    else
      # 校验失败
      
    end
    
    $redis.del(key)
    
    render text: 'ok'
  end
  
  # 点乐
  def dianjoy
    
  end
  
  # 点入
  def dianru
    order = params[:hashid]
    
    # 开发者appid
    app   = params[:appid]
    
    key = app + order
    # 由于网络原因重复回调了多次相同的订单数据
    if $redis.get(key).present?
      # 返回403
      render json: {message:"重复提交", success:"true"}
      return
    end
    
    $redis.set(key, '1')
    
    # 应用名或者广告名称
    ad    = params[:adname]
    
    # 用户ID
    user_id = params[:userid]
    
    # 用户可赚取的积分
    points = params[:point]
    
    str = "?hashid=#{params[:hashid]}&appid=#{params[:appid]}&adid=#{params[:adid]}&adname=#{params[:adname]}&userid=#{params[:userid]}&mac=#{params[:mac]}&deviceid=#{params[:deviceid]}&source=#{params[:source]}&point=#{params[:point]}&time=#{params[:time]}&appsecret=#{SiteConfig.dianru_dev_secret}"
    signature = Digest::MD5.hexdigest(str)
    
    # 参数签名结果
    sig = params[:checksum]
    if signature == sig
      # 参数校验正确
      count = ChannelCallbackLog.where(chn_id: app, order_id: order, uid: user_id).count
      if count == 0
        # 保存记录
        cb_params = []
        params.each do |k,v|
          cb_params << "#{k}=#{v}"
        end
        if ChannelCallbackLog.create(chn_id: app, order_id: order, uid: user_id, ad_name: ad, earn: points, callback_params: cb_params, result: 'ok')
          $redis.del(key)
          render json: { message:"成功", success: true }
        else
          $redis.del(key)
          render json: { message:"失败", success: false }
        end
      end
    else
      # 校验失败
      $redis.del(key)
      render json: { message:"校验失败", success: false }
    end
    
    # $redis.del(key)
    
    # render text: 'ok'
  end
  
  # 万普
  def waps
    order = params[:order_id]
    
    # 开发者appid
    app   = params[:app_id]
    
    key = app + order
    # 由于网络原因重复回调了多次相同的订单数据
    if $redis.get(key).present?
      # 返回403
      render json: {message:"重复提交", success: true}
      return
    end
    
    $redis.set(key, '1')
    
    # 应用名或者广告名称
    ad    = params[:ad_name]
    
    # 用户ID
    user_id = params[:key]
    
    # 用户可赚取的积分
    points = params[:points]
    
    str = params[:adv_id] + params[:app_id] + params[:key] + params[:udid] + params[:bill].to_s + params[:points].to_s + CGI.escape(params[:activate_time]) + params[:order_id] + SiteConfig.waps_dev_secret || ''
    signature = Digest::MD5.hexdigest(str).upcase
    
    # 参数签名结果
    sig = params[:wapskey]
    if signature == sig
      # 参数校验正确
      count = ChannelCallbackLog.where(chn_id: app, order_id: order, uid: user_id).count
      if count == 0
        # 保存记录
        cb_params = []
        params.each do |k,v|
          cb_params << "#{k}=#{v}"
        end
        if ChannelCallbackLog.create(chn_id: app, order_id: order, uid: user_id, ad_name: ad, earn: points, callback_params: cb_params, result: 'ok')
          $redis.del(key)
          puts '保存成功'
          render json: {message:"成功", success: true}
        else
          $redis.del(key)
          puts '保存失败'
          render json: {message:"失败", success: false}
        end
      else
        $redis.del(key)
        puts '已经回调成功一次'
        render json: {message:"已经回调成功过", success: true}
      end
    else
      # 校验失败
      $redis.del(key)
      puts '校验失败'
      render json: {message:"校验失败", success: false}
    end
  end
    
end