class PromotionProductsUniquenessValidator < ActiveModel::Validator
  def validate_each(record, attribute, value)
    record.errors[attribute] << t("Products must be unique") unless value.map(&:name).uniq.size == value.size
  end
end