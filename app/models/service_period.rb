#encoding: utf-8
class ServicePeriod < ActiveRecord::Base
  belongs_to :branch

  validate :service_period_validity

  def service_period_validity
    self.branch.service_periods.each do |service_period|
      if service_period.id != self.id
        if service_period.is_in_service_time?(self.service_period_start) or service_period.is_in_service_time?(self.service_period_end) \
          or self.is_in_service_time?(service_period.service_period_start) or self.is_in_service_time?(service_period.service_period_end)
          errors.add(:base, '时间段设置有重叠！')
        end
      end
    end if self.branch.present?
  end

  def is_in_service_time?(now)
    now_time = self.class.time_since_beginning_of_day(now)
    start_time = self.class.time_since_beginning_of_day(service_period_start)
    end_time = self.class.time_since_beginning_of_day(service_period_end)
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