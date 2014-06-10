#encoding:utf-8;
class FormElement < ActiveRecord::Base
  validates_presence_of :statement
  acts_as_paranoid
  belongs_to :branch
  belongs_to :shop
  belongs_to :form_element
  has_many :form_elements, dependent: :destroy
  accepts_nested_attributes_for :form_elements, allow_destroy: true
  has_many :options, class_name: 'FormElementOption', foreign_key: :form_element_id

  Regexs={none: //, email: /^(\w)+(\.\w+)*@(\w)+((\.\w{2,3}){1,3})$/, phone: /^\d{8,13}$/, number: /^\d{1,2}$/, text_range: /^\w{6,70}$/}
  class << self
    def by_branch_with_options(branch)
      includes(:options).where("form_elements.branch_id = ?", branch.id).
      where("form_elements.form_element_id is null or form_elements.form_element_id = 0").
      order("form_elements.sequence")
    end

    def by_branches_with_options(branch_ids)
      includes(:options).where(:branch_id => branch_ids).
      where("form_elements.form_element_id is null or form_elements.form_element_id = 0").
      order("form_elements.sequence")
    end
  end
end
