#encoding: utf-8
class DeliveryTime < ActiveRecord::Base
  belongs_to :branch

  validates :time_advance, presence: true, :numericality => { :greater_than_or_equal_to => 0}

  validate :delivery_time_validity

  def delivery_time_validity
    self.branch.delivery_times.each do |delivery_time|
      if delivery_time.id != self.id
        if delivery_time.is_in_delivery_time?(self.delivery_time_start) or delivery_time.is_in_delivery_time?(self.delivery_time_end) \
          or self.is_in_delivery_time?(delivery_time.delivery_time_start) or self.is_in_delivery_time?(delivery_time.delivery_time_end)
          errors.add(:base, '时间段设置有重叠！')
        end
      end
    end
  end

  def is_in_delivery_time?(now)
    now_time = self.class.time_since_beginning_of_day(now)
    start_time = self.class.time_since_beginning_of_day(delivery_time_start)
    end_time = self.class.time_since_beginning_of_day(delivery_time_end)
    if start_time <= end_time
      start_time <= now_time and now_time < end_time
    else
      start_time <= now_time or now_time < end_time
    end
  end

  def self.time_since_beginning_of_day(the_time)
    the_time.to_i - the_time.beginning_of_day.to_i
  end
end