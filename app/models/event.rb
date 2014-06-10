#encoding: utf-8
class Event < ActiveRecord::Base
  CLICK_EVENT = "CLICK"
  KEY_PREFIX = 'key_'
  SYSTEM_KEY  = [
    ["获得帮助","#{KEY_PREFIX}0"],
    ["获得点餐链接", "#{KEY_PREFIX}1"],
    ["获得促销活动", "#{KEY_PREFIX}2"],
    ["获得历史订单", "#{KEY_PREFIX}3"],
    ["查询会员信息", "#{KEY_PREFIX}4"],
    ["激活客服系统", "#{KEY_PREFIX}CustomerServiceSystemMaterial"]
  ]
  EVENTTYPES = [[I18n.t('subscribe'), 'subscribe'],
    [I18n.t('unsubscribe'), 'unsubscribe'],
    [I18n.t('unmatch'), 'unmatch'],
    [I18n.t('KEYWORD_AUTOREPLY'), 'KEYWORD_AUTOREPLY'],
    [I18n.t('CLICK'), CLICK_EVENT]]
  validates :event, presence: true
  validates :event, uniqueness:{ message: I18n.t('event.uniq.event'), scope: :shop_id },
      unless: :is_event_sharable?
  validates :event_key, presence: true, uniqueness:{ message: I18n.t('event.uniq.event_key'), scope: [:shop_id, :event] }, if: :is_keyword_event?
  belongs_to :material
  validates :material, presence: true, unless: :is_system_keyword
  has_many :menus, dependent: :destroy
  belongs_to :shop
  attr_accessor :event_text
  scope :get_generalize_events, -> {joins(material: :articles).where("articles.support_promotion = ?", true).where("expiration_time > ?", DateTime.now)}
  scope :unmatch_event, -> {where(event: "unmatch")}
  scope :keyword_autoreply_events, -> {where(event: "KEYWORD_AUTOREPLY")}

  def self.event_name(event_param)
    event_nodes = Event::EVENTTYPES.select{|event| event[1]==event_param}
    unless event_nodes.empty?
      event_nodes[0][0]
    else
      ""
    end
  end

  def self.data_for_select(shop)
    [["回复素材", Material.valid_materials(shop.materials).map{|material| [material.material_name, material.id]}],[ "回复消息", SYSTEM_KEY]]
  end

  def self.autoreply_event_str
    'KEYWORD_AUTOREPLY'
  end

  def self.unmatch_event_str
    'unmatch'
  end

  def self.click_event_str
    CLICK_EVENT
  end


  def self.is_click_event?(event1)
    event1 == CLICK_EVENT
  end

  #判断event是否允许共享
  def is_event_sharable?
    event == CLICK_EVENT or event == 'KEYWORD_AUTOREPLY'
  end

  def is_keyword_event?
    event == 'KEYWORD_AUTOREPLY'
  end

  def is_click_event?
    event == CLICK_EVENT
  end

  def self.event_types_for_subscribe_account
    EVENTTYPES[1..3]
  end

  def self.event_types_for_service_account
    EVENTTYPES[1..4]
  end

end