class ErrorNotSubscribeWeixin < StandardError; end

class ClientApplicationController < ApplicationController
  before_action :check_current_branch
  before_filter :check_branch_expired
  before_filter :redirect_if_not_mobile
  skip_before_filter :authenticate_account!
  before_filter :set_cart_id
  layout 'mobile/application'

  def read_site_config
    @site_config_support_company = SiteConfig.where(key:SiteConfig::SITECONFIG_SUPPORT_COMPANY).first_or_create(
      :display_name=>"技术支持", :value_type=>"string", :value_s=>"拓单宝").value
    @site_config_support_company_url = SiteConfig.where(key:SiteConfig::SITECONFIG_SUPPORT_COMPANY_URL).first_or_create(
      :display_name=>"技术支持URL", :value_type=>"string", :value_s=>"http://www.tuodanbao.com").value
  end

  def validate_user
    fakeUserName = request.query_parameters[:fakeUserName]||cookies[:fakeUserName]
    userId = request.query_parameters[:userId]||cookies[:userId]
    if not mobile_device?
      return
    end
    if fakeUserName.nil? or userId.nil?
      raise ErrorNotSubscribeWeixin
    end
    user =@current_shop.users.find_by_fake_user_name(fakeUserName)
    if user.id == userId.to_i
      @current_user = user
    else
      raise ErrorNotSubscribeWeixin
    end
  end

  def render_not_subscribe_weixin
    response_to  do |format|
      format.json {}
      format.html{
        render :template => 'errors/not_subscribe_weixin', :layout => 'wechat_client'
      }
    end
  end
  rescue_from ErrorNotSubscribeWeixin, :with=> :render_not_subscribe_weixin
end