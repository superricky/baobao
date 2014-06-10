#encoding: utf-8
class AgentRel < ActiveRecord::Base
  validates_presence_of :agent_from, :agent_to
  validates_uniqueness_of :agent_id, :scope=> :agent_zone_id
  validate :agent_from_lt_agent_to
  belongs_to :agent
  belongs_to :agent_zone

  def agent_from_lt_agent_to
    if self.agent_from+1.day >= self.agent_to
      self.errors.add(:agent_from, "必须小于代理截止日期")
    end
  end
end
