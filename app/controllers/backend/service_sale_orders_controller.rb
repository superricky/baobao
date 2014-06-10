#encoding: utf-8
class Backend::ServiceSaleOrdersController < BackendApplicationController

  before_action :set_service_sale_order, only: [:show, :pay_with_alipay]


  def index
    if current_account.is_admin? and @current_shop.nil?
      @service_sale_orders = ServiceSaleOrder.all
    else current_account.is_boss?
      @service_sale_orders = @current_shop.service_sale_orders
    end
  end

  def show
  end

  def new
  end

  def create
    service_product = ServiceProduct.find(params[:service_product_id])
    @service_sale_order = @current_shop.service_sale_orders.build({
        :out_trade_no      => Time.now.strftime("%Y%m%d%H%M%S%s"),         # 20130801000001
        :subject           => service_product.subject,   # Writings.io Base Account x 12
        :price             => service_product.amount,
        :quantity          => 1,
        :discount          => 0,
        :service_product => service_product
      })
    if @service_sale_order.save
      redirect_to [:backend, @current_shop, @service_sale_order]
    else
      flash[:error] = @service_sale_order.errors.full_messages.join(",")
      redirect_to backend_shop_service_products_url(@current_shop)
    end
  end

  def pay_with_alipay
    pay_by_service_order_with_alipay(@service_sale_order)
  end

  private

  def pay_by_service_order_with_alipay(service_sale_order)
    options = {
      :out_trade_no      => service_sale_order.out_trade_no,
      :subject           => service_sale_order.subject,
      :price             => service_sale_order.price,
      :quantity          => service_sale_order.quantity,
      :discount          => service_sale_order.discount,
      :logistics_type    => 'DIRECT',
      :logistics_fee     => '0',
      :logistics_payment => 'SELLER_PAY',
      :return_url        => backend_shop_service_sale_order_url(@current_shop, service_sale_order.id),
      :notify_url        => alipay_notify_url(service_sale_order.id),
    }
    url = Alipay::Service.create_direct_pay_by_user_url(options)
    redirect_to url
  end

  def set_service_sale_order
    if current_account.is_admin?
      @service_sale_order = ServiceSaleOrder.find(params[:id])
    elsif current_account.is_boss?
      @service_sale_order = @current_shop.service_sale_orders.find(params[:id])
    end
  end

end