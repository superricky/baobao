class ApiKey < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  before_create :generate_access_token
  before_create :set_expiration
  before_create :create_location

  default_scope {order("created_at DESC")}

  def expired?
    Time.now >= self.expires_at
  end

  def create_location
    loc =  Geokit::Geocoders::MultiGeocoder.geocode(self.ip_address)
    if loc.present?
      self.location = loc.city||loc.state
    end
  end

  private
  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

  def set_expiration
    self.expires_at = Time.now + 30.minutes
  end
end
