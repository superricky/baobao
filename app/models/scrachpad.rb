class Scrachpad < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :branch
  belongs_to :shop
  belongs_to :user
  belongs_to :order
  default_scope {order('created_at DESC')}

  after_save :after_change_scrachpad_to_open

  private
  def after_change_scrachpad_to_open
    if is_opened_changed? && is_opened?
      ScrachpadWorker.perform_in(1.second, order.id) if order && order.branch.separate_notice_of_praise_and_new_order
    end
  end
end
