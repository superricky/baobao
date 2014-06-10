class FormElementSelect < FormElement
  has_many :options, class_name: 'FormElementOption', foreign_key: :form_element_id
end
