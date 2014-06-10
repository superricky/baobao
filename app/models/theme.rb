#encoding:utf-8
class Theme < ActiveRecord::Base
  THEME_IOS="ios"
  THEME_IOS7="ios7"
  THEME_android="android"
  THEME_BB="bb"
  THEME_WIN8="win8"
  THEME_TIZEN="tizen"
  THEME_SYSTEM="theme_system"
  THEME_CUSTOM="theme_custom"

  THEME_TYPES = [[I18n.t(THEME_IOS), THEME_IOS],
  [I18n.t(THEME_IOS7), THEME_IOS7],
  [I18n.t(THEME_android), THEME_android],
  [I18n.t(THEME_BB), THEME_BB],
  [I18n.t(THEME_TIZEN), THEME_TIZEN],
  [I18n.t(THEME_SYSTEM), THEME_SYSTEM],
  [I18n.t(THEME_CUSTOM), THEME_CUSTOM]]

  belongs_to :shop
  validates :background_color, :text_color, :header_bg_color, :header_text_color, :navbar_bg_color, :navbar_text_color, :menu_bg_color, :menu_text_color, format:{with:/\A#[a-f0-9]{6}\Z/i}, :allow_blank => true

  def is_custom?
    theme_type == THEME_CUSTOM
  end

  def theme_types
    THEME_TYPES
  end

  def theme_type_name
    THEME_TYPES.select{|type| type[1]==theme_type}[0][0]
  end
end
