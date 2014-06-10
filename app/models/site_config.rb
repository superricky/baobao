#encoding: utf-8
class SiteConfig < ActiveRecord::Base

  validates :key, uniqueness: true

  SITECONFIG_WEIXIN_HELP_MSG = "weixin_help_msg"
  SITECONFIG_SUPPORT_COMPANY = "support_company"
  SITECONFIG_SUPPORT_COMPANY_URL = "support_company_url"
  SET_APPID_APPSECRED = "set_appId_appSecret"
  ACCEPT_ORDERS_TERMINAL_CONFIGURATION = "accept_orders_terminal_configuration"
  CONFIG_FEYIN_PRINTER_INSTRUCTION = "config_feyin_printer_instruction"

  public
  def is_boolean?
    value_type == 'boolean'
  end

  def is_string?
    value_type == 'string'
  end

  def self.set_appId_appSecret
    #SiteConfig.find_or_create_by_key_and_display_name_and_value_type_and_value_s(SiteConfig::SET_APPID_APPSECRED,"如何获得appId和appSecret", "string" , "http://www.tuodanbao.com")
  end

  def self.accept_orders_terminal_configuration
    #SiteConfig.find_or_create_by_key_and_display_name_and_value_type_and_value_s(SiteConfig::ACCEPT_ORDERS_TERMINAL_CONFIGURATION,"接受订单信息的终端配置", "string" ,"http://www.tuodanbao.com")
  end

  def self.config_feyin_printer_instruction
    #SiteConfig.find_or_create_by_key_and_display_name_and_value_type_and_value_s(SiteConfig::CONFIG_FEYIN_PRINTER_INSTRUCTION, "飞印无线打印机配置", "string", "http://www.tuodanbao.com")
  end

  def value
    if self.is_boolean?
      self.value_b
    elsif self.is_string?
      self.value_s
    end
  end
end
