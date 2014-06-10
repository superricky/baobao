#encoding: utf-8
class PostThread < ActiveRecord::Base
  has_many :posts
  belongs_to :account
  validates_presence_of :account, :title, :content
  before_update :update_last_request_time
  has_and_belongs_to_many :post_thread_labels
  validates_presence_of :post_thread_label_ids

  validate :limit_thread_number_for_each_one
  default_scope {order("updated_at, requested_times, created_at DESC")}
  scope :viewable, ->(account){
    where(" account_id= ? or is_published=?", account.id, true) unless account.is_admin?
  }

  include Workflow
  workflow do
    state :new do
      event :open, :transitions_to => :opened
      event :close, :transitions_to => :closed
    end
    state :opened do
      event :close, :transitions_to => :closed
      event :open, :transitions_to => :opened
    end
    state :closed do
      event :open, :transitions_to => :opened
    end
  end

  def open
  end
  def close
  end

  def workflow_state_name
    I18n.t "post_thread.workflow_state.#{current_state}"
  end

  def request
    time = last_requestd_at||created_at
    if time > 2.days.ago
      self.errors.add(:base, "对不起，距离发布需求或上次催促时间必须满48小时才能再次催促处理!")
      false
    else
      self.increment!(:requested_times)
      true
    end
  end

  def toggle_publish
    self.update_attribute(:is_published, !self.is_published)
  end

  private
  def update_last_request_time
    if self.requested_times_changed?
      self.last_requestd_at = DateTime.now
    end
  end

  def limit_thread_number_for_each_one
    self.account.post_threads.length < 10
  end
end
