class FollowTasksController < ApplicationController

  def show
    nb_code = params[:uid]
    @user = User.find_by(nb_code: nb_code)
    @task = FollowTask.find(params[:id])
  end
  
  # 回调
  def callback
    # 回调订单号
    order = params[:order]
    
    # 任务ID
    task_id = params[:task_id]
    
    # uid
    nb_code = params[:uid]
    
    # 时间戳
    time = params[:time]
    
    # 签名
    sig = params[:sig]
    
    key = task_id + order
    # 由于网络原因重复回调了多次相同的订单数据
    if $redis.get(key).present?
      # 返回403
      render json: {message:"重复提交", success: true}
      return
    end
    
    $redis.set(key, '1')
    
    user = User.find_by(nb_code: nb_code)
    task = FollowTask.find_by(task_id: task_id)
    if task.blank? or user.blank?
      $redis.del(key)
      render json: { message: '未找到数据', success: false }
      return
    end
    
    if not task.opened
      $redis.del(key)
      render json: { message: '您的任务已经下架', success: false }
      return
    end
    
    str = task.dev_secret + order + task_id + nb_code + time.to_s
    signature = Digest::MD5.hexdigest(str)
    
    if signature == sig
      count = FollowTaskLog.where(uid: nb_code, follow_task_id: task.id).count
      if count == 0
        cb_params = []
        params.each do |k,v|
          cb_params << "#{k}=#{v}"
        end
        if FollowTaskLog.create(uid: nb_code, 
                                follow_task_id: task.id,
                                earn: task.earn,
                                callback_params: cb_params)
          $redis.del(key)
          render json: { message: '成功', success: true }
        else
          $redis.del(key)
          render json: { message: '失败', success: false }
        end
      else
        $redis.del(key)
        render json: { message: '已经成功回调一次', success: true }
      end
      
    else
      $redis.del(key)
      render json: { message: '参数校验失败', success: false }
    end
  end
    
end