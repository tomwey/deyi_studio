class Studio < ActiveRecord::Base
  validates :name, :contact_name, :contact_number, presence: true
  
  has_many :studio_grab_tasks
  has_many :app_tasks, through: :studio_grab_tasks
  
  has_many :earning_details
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      self.studio_id = '8' + SecureRandom.random_number.to_s[2..6]
    end while self.class.exists?(:studio_id => studio_id)
  end
  
  def has_progressed_task?(ip)
    $redis.get("#{studio_id}:#{ip}").present?
  end
  
  def today_earnings
    now = Time.zone.now
    @total ||= earning_details.where(created_at: now.beginning_of_day..now.end_of_day).sum(:money)
  end
  
end
