class StudioLoginHistory < ActiveRecord::Base
  belongs_to :studio
  
  scope :today_for, -> (studio, ip) { where(studio_id: studio.id, login_ip: ip, created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day) }
end
