#encoding:utf-8;
class Backend::ShopsController < BackendApplicationController
  before_action :set_shop, only: [:show, :edit, :update, :destroy, :show_my_shop, :config_my_shop, :update_my_shop]

  def index
    @q = Shop.search(params[:q])
    @shops = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 25)
  end

  def change_branch_index
    if @current_shop.update_attribute(:show_detail_for_branch,  params[:shop][:show_detail_for_branch])
      redirect_to backend_shop_theme_path(@current_shop)
    end
  end

  def dashboard
    @popular_branch_access_times = Branch.order_access_times_desc(@current_shop.branches.map(&:id))[0..4]
    @popular_branches = Branch.find(@popular_branch_access_times.map{|arr| arr[0] })
    @popular_products = OrderItem.popular_order_items_of_week(@current_shop).group('order_items.name').sum(:quantity).sort_by{|k,v| v}.reverse[0..4]
    @orders_of_7_days = @current_shop.orders.for_7_days
    @products_with_no_stock = @current_shop.products.where(:stock=>0)
    @comments_wait_for_pub = @current_shop.branch_comments.where(:can_pub => false)
    @user_applying_vip = @current_shop.users.appling_vips
    @order_of_today = @current_shop.orders.for_today
    @order_today=@order_of_today.count
    @canceled_orders_of_today = @order_of_today.where(:state=>[Order::CANCELED])
    @finished_orders_of_today = @order_of_today.where(:state=>[Order::COMPLETED, Order::DELIVERED])
    @wait_finished_orders_of_today = @order_of_today.where(:state=>[Order::DELIVERING, Order::CONFIRMED, Order::WAIT_CONFIRMED])

    @amount = {}
    @amount[:total] = @orders_of_7_days.inject(0.0){|sum, order| sum += order.amount }
    @amount[:delivered_total] = @orders_of_7_days.where(:state=>[Order::COMPLETED, Order::DELIVERED]).inject(0.0){|sum, order| sum += order.amount }
    @amount[:wait_finished_total]= @orders_of_7_days.where(:state=>[Order::DELIVERING, Order::CONFIRMED, Order::WAIT_CONFIRMED]).inject(0.0){|sum, order| sum += order.amount }
    @amount[:cancelled_total]= @orders_of_7_days.where(:state=>[Order::CANCELED]).inject(0.0){|sum, order| sum += order.amount }
  end
  def show_my_shop
  end

  def config_my_shop
  end

  def validation_domain
    @shop = @current_shop
    shop = @shop.validation_domain request.host
    respond_to do |f|
      if shop && shop.errors.empty?
        f.html {redirect_to request.referer}
      else
        if shop && !shop.errors.empty?
          flash[:notice] = shop.errors.full_messages.join "\n"
        else
          flash[:notice] = "域名验证失败"
        end
        f.html {redirect_to request.referer}
      end
    end
  end

  def update_my_shop
    respond_to do |format|
      if @current_shop.update(shop_params)
        format.html { redirect_to show_my_shop_backend_shop_path(@current_shop.slug), notice: t('Shop was successfully updated.') }
        format.json { head :no_content }
      else
        @shop = @current_shop
        format.html { render action: 'config_my_shop' }
        format.json { render json: @current_shop.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /shops/1
  # GET /shops/1.json
  def show
  end

  # GET /shops/new
  def new
    @shop = Shop.new
  end

  # GET /shops/1/edit
  def edit
  end

  # POST /shops
  # POST /shops.json
  def create
    @shop = Shop.new(shop_params)
    @shop.enable_new_version = false

    respond_to do |format|
      if @shop.save
        format.html { redirect_to backend_shop_shop_steps_path(@shop) + "/sms_message" }
        format.json { render action: 'show', status: :created, location: @shop }
      else
        format.html { render action: 'new' }
        format.json { render json: @shop.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shops/1
  # PATCH/PUT /shops/1.json
  def update
    respond_to do |format|
      if @shop.update(shop_params)
        format.html { redirect_to backend_shop_path(@shop), notice: t('Shop was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @shop.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shops/1
  # DELETE /shops/1.json
  def destroy
    @shop.destroy
    respond_to do |format|
      format.html { redirect_to backend_shops_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shop
      @shop = Shop.find(params[:id])
      @current_shop = @shop
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shop_params
      params[:shop][:domain] = "" if params[:shop][:domain] && params[:shop][:domain].include?(request.domain) || params[:shop][:domain] == request.host
      if current_account.is_admin?
        params.require(:shop).permit(:qrcode, :name, :slug, :introduction, :is_open,
          :expiration_time, :telephone, :max_branches_count, :image, :image_cache,
          :default_reply_content_type, :charge_method, :left_order_count, :welcome_msg,
          :use_sms, :max_sms_count, :use_sms_validation, :aid, :show_detail_for_branch,
          :max_validation_code_times_in_day, :use_credits, :money_for_each_credit,
          :support_wallet_pay, :support_credits_pay, :credit_for_each_money, :enable_new_version,
          :hide_support_company, :max_branch_sliders, :award_credits_at_follow, :award_credits, :reply_num_of_orders,
          :least_promotion_number, :state, :product_image_limit, :product_slider_limit, :support_link, :support_link_name, :support_auto_buy_service, :domain, :copy_right_footer)
      else
        params.require(:shop).permit(:name, :qrcode, :introduction, :telephone,:image, :default_reply_content_type,
        :welcome_msg, :use_sms, :use_sms_validation, :show_detail_for_branch, :max_validation_code_times_in_day,
        :use_credits, :money_for_each_credit, :enable_new_version, :reply_num_of_orders,
        :support_wallet_pay, :support_credits_pay, :credit_for_each_money, :enable_new_version, :max_branch_sliders,
        :award_credits_at_follow, :award_credits, :least_promotion_number, :domain)
      end
    end
end