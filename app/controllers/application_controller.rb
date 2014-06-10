class ErrorNotFromWeixin < StandardError; end
class ErrorNotFromMobileDevice < StandardError;end
class ErrorShopExpired < StandardError; end
class ErrorNoAuthorityToOperation < StandardError; end
class ErrorNotLogin < StandardError; end
class ErrorShopNotExist < StandardError; end
class ErrorBranchExpired < StandardError; end
class SmsMsgNoFeeException < StandardError; end
class SmsMsgSendErrorException < StandardError; end
class SmsMsgTooFrequently < StandardError; end
class ValidationSmsMsgOverLimit < StandardError; end
class BranchOrShopNotUseSmsValidation < StandardError; end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_shop_id
  before_filter :check_shop_id
  #around_filter :global_request_logging

  include SessionsHelper
  helper_method :current_cart
  helper_method :current_user
  helper_method :mobile_device?


  rescue_from ActionController::RoutingError, :with => :render_404

  protected
  rescue_from ActionController::InvalidAuthenticityToken, with: :render_422

  def after_sign_in_path_for(resource)
    respond_to do |format|
      format.html {
        (stored_location_for(resource) rescue "/")|| get_root_path
      }
      format.json {}
    end
  end

  def get_root_path
    if current_account.nil?
      "/"
    elsif current_account.is_admin?
      backend_system_admin_root_path
    elsif current_account.is_boss?
      dashboard_backend_shop_path(current_account.shop.slug)
    elsif current_account.is_worker?
      backend_shop_branches_path(current_account.shop.slug)
    else
      "/"
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    backend_login_path
  end



  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :login_id
    devise_parameter_sanitizer.for(:sign_in) << :login_id
    devise_parameter_sanitizer.for(:account_update) << :login_id
  end

  def default_url_options
    if @hash_of_additional_params
      @hash_of_additional_params
    else
      {}
    end
  end

  def current_cart
    @current_cart
  end

  def current_user
    @current_user
  end

  def validate_user_info
    fakeUserName = request.query_parameters[:fakeUserName]||params[:fakeUserName]
    userId = request.query_parameters[:userId]||params[:userId]
    if not mobile_device?
      return
    end
    if fakeUserName.nil? or userId.nil?
      raise ErrorNotFromWeixin
    end
    @hash_of_additional_params = {:userId => userId, :fakeUserName => fakeUserName, :source=>"mp.weixin.qq.com"}
    user =@current_shop.users.find_by_fake_user_name(fakeUserName)
    if user && user.id == userId.to_i
      @current_user = user
    else
      raise ErrorNotFromWeixin
    end
  end

  def set_cart_id
    validate_user_info
    #logger.info "set_cart_id #{@current_user.to_json}"
    apply_new_cart(@current_user, @current_branch)
  end

  def check_branch_expired
    unless @current_branch.nil?
      if ( current_account.nil? or current_account.is_worker?) and @current_branch.is_expired?
          raise ErrorBranchExpired
      end
    end
  end

  def check_current_branch
    unless ["sessions", "registrations", "confirmations", "unlocks"].include? controller_name
      if params[:branch_id].present?
        @current_branch = @current_shop.branches.find(params[:branch_id]) rescue nil
        unless @current_branch.present?
          render_404
        else
          @custom_ui_setting = @current_branch.get_custom_ui_setting
        end
      end
    end
  end

  def apply_new_cart(user, branch)
    if branch.nil?
      return
    end
    begin
      @current_cart = user.carts.find_by_branch_id(branch.id)
      create_new_cart(user, branch)
    rescue ActiveRecord::RecordNotFound
      create_new_cart(user, branch)
    end
  end

  def create_new_cart(user, branch)
    if @current_cart.nil?
      @current_cart = user.carts.create(:shop => @current_shop, :branch => branch)
    end
  end

  def redirect_if_not_mobile

    unless mobile_device?
      raise ErrorNotFromMobileDevice
    end
  end

  def render_not_from_weixin
      render :template => 'errors/not_from_weixin_client', :layout => 'mobile/empty'
  end

  def render_not_from_mobile_device
    #render :template => 'errors/not_mobile_device', :layout => 'mobile/empty'
    redirect_to 'http://www.tuodanbao.com'
  end

  def redirect_to_login
    redirect_to backend_login_path, notice: t('Please sign in')
  end

  def render_no_authoriy
    render :template => 'errors/no_authoriy_to_operate', :layout => 'backend'
  end

  def render_shop_not_exist
    render :template => 'errors/shop_not_exist', :layout => 'backend'
  end

  def mobile_device?
    request.user_agent =~ /MicroMessenger|Mobile|webOS|android|iphone|ipad|ios|meego|ipod|kindle|phone|psp|symbian/i
  end

  def render_shop_expired
    render_expired("微信账户\"#{@current_shop.name}\"")
  end

  def render_branch_expired
    render_expired("商户\"#{@current_branch.name}\"")
  end

  def render_expired(msg_title)
    if request.path =~ /\A\/shop\/[a-zA-Z0-9]+\/api\Z/
      body = request.body.read
      body = Hash.from_xml(body).to_options[:xml].to_options


        @response = Message.new(
          :msg_type => 'text',
          :from_user_name => body[:ToUserName],
          :content => "对不起，#{msg_title}服务已到期或订单配额已耗尽，请管理员续费后继续使用，谢谢您对融商的支持！电话: 0731-89903595，售后服务：0731-89903595",
          :create_time => Time.now.to_i,
          :to_user_name => body[:FromUserName]
        )

        respond_to do |format|
          format.xml {
            render :template =>'messages/create'
            }
        end
    elsif mobile_device?
      respond_to do |format|
        format.html {
          render :template => "errors/shop_expired", :layout => 'mobile/empty', :locals => {msg_title:msg_title}
        }
        format.json {
          @error_info = {errors: ['该商户已配额耗尽已过期，请选择其他商户购买商品']}
          render json: @error_info, :status => :bad_request
        }
      end
    else
      render :template => "errors/shop_expired", :layout => 'backend', :locals => {msg_title:msg_title}
    end
  end




  include ApplicationHelper

  def define_current_shop
    if not @current_shop_id.nil?
      @current_shop = Shop.find(@current_shop_id) rescue nil
      raise ErrorShopNotExist if @current_shop.nil?
    end
  end

  def set_shop_id
    if (not current_account.nil?) and (not current_account.shop.nil?)
      shop_id = current_account.shop.id
    end
    @current_shop_id = shop_id || params[:shop_slug] || params[:shop_id]
    if @current_shop_id.nil? and controller_name == "shops" and params[:id].present?
      @current_shop_id = params[:id]
    end
  end

  def render_no_content
    head :no_content
  end

  def check_shop_id
    unless ["sessions", "registrations", "confirmations", "unlocks"].include? controller_name
      define_current_shop

      if current_account.present? and !current_account.is_admin? and (current_account.shop != @current_shop)
        @current_shop = current_account.shop
        redirect_to backend_shop_path(@current_shop)
      end

      if @current_shop and @current_shop.is_expired? and (not ["service_sale_orders", "service_products"].include? controller_name)
        if current_account.nil? or !current_account.is_admin?
          raise ErrorShopExpired
        end
      end
    end
  end

  def global_request_logging
    # Rails.logger.info "REQUEST INSPECTOR"
    # Rails.logger.info "  [REQUEST_URI] #{request.headers['REQUEST_URI'].inspect}"
    # Rails.logger.info "  [RAW_POST]: #{request.raw_post.inspect}"
    # Rails.logger.info "  [PARAMS]: #{request.params.inspect}"
    # Rails.logger.info "  [HTTP_AUTHORIZATION] #{request.headers['HTTP_AUTHORIZATION'].inspect}"
    # Rails.logger.info "  [CONTENT_TYPE]: #{request.headers['CONTENT_TYPE'].inspect}"
    # Rails.logger.info "  [HTTP_ACCEPT] #{request.headers['HTTP_ACCEPT'].inspect}"
    # Rails.logger.info "  [HTTP_HOST] #{request.headers['HTTP_HOST'].inspect}"
    # Rails.logger.info "  [HTTP_USER_AGENT] #{request.headers['HTTP_USER_AGENT'].inspect}"
    begin
      yield
    ensure
    #logger.info "response_status: #{response.body}"
    end
  end

  rescue_from ErrorNotFromWeixin, :with => :render_not_from_weixin
  rescue_from ErrorNotFromMobileDevice, :with => :render_not_from_mobile_device
  rescue_from ErrorShopExpired, :with => :render_shop_expired
  rescue_from ErrorNoAuthorityToOperation, :with=>:render_no_authoriy
  rescue_from ErrorNotLogin, :with => :redirect_to_login
  rescue_from ErrorShopNotExist, :with => :render_shop_not_exist
  rescue_from ErrorBranchExpired, :with=> :render_branch_expired

  private
  def render_404(exception = nil)
    if exception
        logger.info "Rendering 404: #{exception.message}"
    end
    respond_to do |format|
      format.html{ render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false}
    end
  end

  def render_422(exception = nil)
    if exception
        logger.info "Rendering 422: #{exception.message}"
    end
    respond_to do |format|
      format.html{ render :file => "#{Rails.root}/public/422.html", :status => 404, :layout => false}
      format.json{ render json: {errors: ["您的本次操作被拒绝.", "由于您长时间未操作或返回键后执行了过期的操作，导致本次操作失败！"]}, :status => 422}
    end
  end

  def set_webstore_shop_and_branch
    shop = Subdomain.filter_slug_from_subdomain request
    if shop.present?
      @current_shop = shop
      params[:shop_id] = @current_shop.id
    elsif params[:shop_id]
      @current_shop = Shop.find params[:shop_id]
    else
      @current_shop = Shop.find_by_domain_and_validated_domain request.host, true
    end

    if params[:branch_id]
      @current_branch = Branch.find_by_id_and_is_open params[:branch_id], true
      @current_shop = @current_branch.shop
    end
    @current_branches = @current_shop.online_branches if @current_shop

    @technical_support = SiteConfig.where(key: SiteConfig::SITECONFIG_SUPPORT_COMPANY).first.value rescue ""
  end
end
