class BackendApplicationController < ApplicationController
  # reset captcha code after each request for security
  after_filter :reset_last_captcha_code!

  layout "backend/application"

  before_action :check_current_branch
  before_filter :params_filter
  before_action :authenticate_account!
  before_filter :set_current_account
  before_filter :check_branch_expired
  before_action :get_top_info

  load_and_authorize_resource


  def params_filter
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  rescue_from CanCan::AccessDenied do |exception|
    if current_account.nil?
      session[:next] = request.fullpath
      redirect_to backend_login_url, :alert => t("You have to log in to continue")
    else
      if request.env["HTTP_REFERER"].present?
        redirect_to :back, :alert => t("you don not have the right")
      else
        redirect_to get_root_path, :alert => t("you don not have the right")
      end
    end
  end

  def set_current_account
    @current_account = current_account
  end
  def get_top_info
    if !current_account.is_admin?
      @user_count= @current_shop.users.appling_vips.count
      @popular_product = OrderItem.popular_order_items_of_week(@current_shop).group('order_items.name').sum(:quantity).sort_by{|k,v| v}.max
      if @popular_product.nil?
          @popular_product="无"
      else
          @popular_product=@popular_product[0]
      end
      @popular_branch_access_count= Branch.order_access_times_desc(@current_shop.branches.map(&:id)).first
      if @popular_branch_access_count.nil?
        @popular_branch_access_count=0
      else
        @popular_branch_access_count=@popular_branch_access_count[1]
      end
      @orders_sum = @current_shop.orders.where(:state=>Order::WAIT_CONFIRMED).count
    end

  end


  def check_has_admin_priv
    current_account.is_admin?
  end

  def check_has_boss_priv
    check_has_admin_priv or current_account.is_boss?
  end

  def check_has_worker_priv
    check_has_boss_priv or current_account.is_worker?
  end

  private

  def namespace
    controller_name_segments = params[:controller].split('/')
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join('/').camelize
  end

  def current_ability
    @current_ability ||= Ability.new(current_account, namespace)
  end

end