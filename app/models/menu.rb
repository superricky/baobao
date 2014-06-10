#encoding: utf-8
class Menu < ActiveRecord::Base
  MENUTYPES = ["button"]
  EVENTTYPES = ["click", "view"]
  validates :name, :event_type, :menu_type, presence: true
  validates :name, uniqueness:{:scope=>:shop_id}
  validates :material, presence: true, if: :is_click_event?
  belongs_to :parent_menu, class_name: "Menu"
  has_many :submenus, class_name: "Menu", foreign_key: "parent_menu_id", dependent: :destroy
  belongs_to :material
  belongs_to :event
  belongs_to :shop
  has_and_belongs_to_many :system_configs, :uniq => true
  scope :root_menus, ->{where(:parent_menu_id=>nil)}
  validate :check_menu_count

  def key_value
    self.material ? self.material_id : self.keyword
  end

  def key_value_name
    self.material ? (self.material.material_name rescue nil) : (Event::SYSTEM_KEY.select{|a| a[1] == "#{Event::KEY_PREFIX}#{self.keyword}"}.first[0] rescue nil)
  end

  def self.data_for_select(shop, system_config)
    [["回复素材", shop.materials.all.map{|material| [(material.material_name rescue nil),material.id]}.uniq{|a| a[0]}],[ "回复消息", reply_message(system_config)]]
  end

  def self.reply_message(system_config)
    unless system_config.gonghao_type
      reply_message = Event::SYSTEM_KEY + [["获得推广二维码", "#{Event::KEY_PREFIX}6"]]
    else
      Event::SYSTEM_KEY
    end
  end

  def check_menu_count
    if self.shop.menus.root_menus.count > 3 and self.parent_menu.nil?
      self.errors.add(:base, "微信公众帐号最多允许新建3个一级菜单")
    elsif parent_menu_id.present? and self.parent_menu.submenus.count > 5
      self.errors.add(:base, "微信公众帐号最多允许每个一级菜单最多包含5个子菜单")
    end
  end

  private
    def is_click_event?
      event_type == 'click' and !keyword.present? and parent_menu.present?
    end
end
