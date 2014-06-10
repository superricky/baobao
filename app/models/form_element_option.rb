class FormElementOption < FormElement
  belongs_to :select, class_name: 'FormElementSelect', foreign_key: :form_element_id
end
