class PushReg < ActiveRecord::Base
  belongs_to :binder, polymorphic: true
  validates :binder, presence: true
end
