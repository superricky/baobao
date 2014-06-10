class CustomUiSetting < ActiveRecord::Base
  belongs_to :branch
  has_one :shop, through: :branch

  def get_value(key)
    text = CustomUiSetting.human_attribute_name(key.to_sym)
    value = self.send key.to_s rescue nil
    if value.present?
      text = value
    end
    text
  end
end
