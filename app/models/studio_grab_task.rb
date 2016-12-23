class StudioGrabTask < ActiveRecord::Base
  belongs_to :studio
  belongs_to :app_task
  
  after_create :decrase_grab_count
  def decrase_grab_count
    app_task.change_grab_count(-1)
    
    $redis.set("#{studio.studio_id}:#{ip}", app_task.task_id)
    
    # 30分钟内失效
    CancelTaskJob.set(wait: 30.minutes).perform_later(self.id, 1)
  end
  
  # def expired?
  #   self.expired_at < Time.zone.now
  # end
  
  def remove_in_progress_task
    $redis.del("#{studio.studio_id}:#{ip}")
  end
  
  # 定义状态机
  state_machine initial: :pending do # 任务开始状态
    state :expired   # 已过期
    state :canceled  # 已取消
    state :completed # 已完成
    
    # 失效
    after_transition :pending => :expired do |log, transition|
      # order.send_pay_msg
      log.app_task.change_grab_count(1)
      log.remove_in_progress_task
    end
    event :expire do
      transition :pending => :expired
    end
    
    # 取消
    after_transition :pending => :canceled do |log, transition|
      log.app_task.change_grab_count(1)
      # $redis.del("#{studio.studio_id}:#{ip}")
      log.remove_in_progress_task
    end
    event :cancel do
      transition :pending => :canceled
    end
    
    # 完成
    after_transition :pending => :completed do |log, transition|
      # 发送消息
      # $redis.del("#{studio.studio_id}:#{ip}")
      log.remove_in_progress_task
      
      log.studio.balance += log.reward
      log.studio.earnings += log.reward
      
      log.studio.save!
      
      EarningDetail.create!(app_task: log.app_task, studio: log.studio, money: log.reward, ip: log.ip)
    end
    event :complete do
      transition :pending => :completed
    end
  end 
end
