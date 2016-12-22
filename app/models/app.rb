class App < ActiveRecord::Base
  validates :name, :icon, :app_size, :appstore_url, :bundle_id, :version, :devices, presence: true
  validates_numericality_of :app_size, :app_price
  validates_uniqueness_of :bundle_id
  
  mount_uploader :icon, AvatarUploader
  
  before_create :set_app_id_if_blank
  def set_app_id_if_blank
    if self.app_id.blank?
      begin
        self.app_id = '8' + SecureRandom.random_number.to_s[2..8]
        # self.save!
      end while self.class.exists?(:app_id => app_id)
    end
  end
  
  def self.prefered_os
    os_config = CommonConfig.prefered_os
    if os_config
      os_config.split(',')
    else
      ['iOS', 'Android']
    end
  end
  
  def self.prefered_devices
    ['Phone', 'Pad', 'All']
  end
end

# t.string :name,     null: false
# t.string :icon,     null: false
# t.string :app_size, null: false # 单位为MB，例如15.59MB
# t.string :appstore_url, null: false
# t.integer :app_id # 如果是iOS平台，那么为苹果商店的apple id，否则自动生成一个唯一的id
# t.string :bundle_id, null: false
# t.string :url_scheme
# t.string :version, null: false
# t.string :os, default: 'iOS'
# t.string :devices, null: false
# t.integer :rank