module FormElementsHelper
  def form_element_regexs
    FormElement::Regexs.keys.map{|k| [t("activerecord.attributes.form_element.regexs.#{k}"), k]}
  end

  def form_element_switch

  end
end
