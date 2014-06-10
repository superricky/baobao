class MessageThread < ActiveRecord::Base
  belongs_to :user
  has_many :messages, dependent: :destroy
  belongs_to :shop

  default_scope {order('updated_at DESC')}

  ransacker :time, :formatter => proc {|v| Date.today - 1.send(v) } do |parent|
    parent.table[:updated_at]
  end
end
