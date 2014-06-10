class AgentZone < ActiveRecord::Base
  has_many :agent_rels
  has_many :agents, through: :agent_rels
  belongs_to :parent_agent_zone, class_name: 'AgentZone'
  scope :root_agent_zones, ->{where(:parent_agent_zone_id=>nil)}
  has_many :sub_agent_zones, class_name: 'AgentZone', foreign_key: :parent_agent_zone_id


  def agents_count
    self.sub_agent_zones.sum{|agent_zone| agent_zone.agents_count} + self.agents.count
  end
end
