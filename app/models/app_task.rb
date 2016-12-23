class AppTask < ActiveRecord::Base
  belongs_to :app
  
  validates :name, :keywords, :task_steps, :price, :start_time, :end_time, :app_id, presence: true
  
  scope :current, -> { where('start_time < :time and end_time > :time', time: Time.zone.now) }
  scope :after, -> { where('start_time > ?', Time.zone.now) }
  # scope :filter_for_st, ->(st) { where("#{st == 0 ? 'put_in_count' : 'st_put_in_count'} != 0") }
  scope :sorted, -> { order('sort desc') }
  scope :recent, -> { order('id desc') }
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      n = rand(10)
      if n == 0
        n = 8
      end
      self.task_id = n.to_s + SecureRandom.random_number.to_s[2..9]
    end while self.class.exists?(:task_id => task_id)
  end
  
  # def change_st_grab_count(n)
  #   count = self.st_grab_count + n
  #   if count >= 0
  #     self.update_attribute(:st_grab_count, count)
  #   end
  # end
  
  # def in_progress?(ip)
  #   $redis.get("#{task_id}:#{ip}").to_s == '1'
  # end
  #
  # def mark_done(ip)
  #   $redis.del("#{task_id}:#{ip}")
  # end
  
end

# name: '任务名称'
# keywords: '关键字'
# task_steps: '任务步骤'
# price: '真实用户价格'
# st_price: '工作室价格'
# put_in_count: '用户任务量'
# st_put_in_count: '工作室任务量'
# grab_count: '用户完成量'
# st_grab_count: '工作室完成量'
# start_time: '任务开始时间'
# end_time: '任务结束时间'
# task_id: '任务ID'
# special_price: '专属任务或非100%奖励扣除'
# app: '所属应用'
# app_id: '所属应用'
# sort: '显示顺序'