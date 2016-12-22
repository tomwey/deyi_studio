class Studio < ActiveRecord::Base
  validates :name, :contact_name, :contact_number, presence: true
  
  before_create :generate_unique_id
  def generate_unique_id
    begin
      self.studio_id = '8' + SecureRandom.random_number.to_s[2..6]
    end while self.class.exists?(:studio_id => studio_id)
  end
  
end
