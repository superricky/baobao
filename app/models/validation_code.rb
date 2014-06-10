class ValidationCode < ActiveRecord::Base
  belongs_to :code_owner, :class_name => "BaseUser"
  validates :code, presence:true

  def initialize(attributes = {})
    super
    generate_code
  end

  def is_activated?
    Time.now <= self.created_at + 1.hour
  end
  private
  def generate_code
    self.code = Random.rand(100000..999999).to_s
  end

end
