class PromotionConfig <ActiveRecord::Base
  PROMOTION_CONFIG_TYPE_STRING = "str"
  PROMOTION_CONFIG_TYPE_INTEGER = "i"
  PROMOTION_CONFIG_TYPE_BOOLEAN = "b"
  PROMOTION_CONFIG_TYPE_DECIMAL = "d"
  belongs_to :promotion
  validates :key, uniqueness: {scope: :promotion_id}
  
  def value 
    if config_value_type == PROMOTION_CONFIG_TYPE_STRING
      config_value_str
    elsif config_value_type == PROMOTION_CONFIG_TYPE_INTEGER
      config_value_i
    elsif config_value_type == PROMOTION_CONFIG_TYPE_BOOLEAN
      config_value_b
    elsif config_value_type == PROMOTION_CONFIG_TYPE_DECIMAL
      config_value_d
    end
  end
end