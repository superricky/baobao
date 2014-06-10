class Agent < ActiveRecord::Base
  validates_presence_of :aid, :name, :balance, :phone
  validates_uniqueness_of :aid
  has_many :agent_rels
  has_many :agent_zones, through: :agent_rels

  accepts_nested_attributes_for :agent_rels
  def shops
    Shop.where(:aid=> self.aid)
  end
end
