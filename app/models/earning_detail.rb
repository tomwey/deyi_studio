class EarningDetail < ActiveRecord::Base
  belongs_to :app_task
  belongs_to :studio
  
  validates :app_task_id, :studio_id, :money, presence: true
end
