#encoding: utf-8
class Backend::OrdersController < BackendApplicationController
  before_action :set_order, only: [:show, :update, :change_state]
  # GET /orders
  # GET /orders.json
  def index
    @orders = @current_branch.orders.where(state: params[:state]).paginate(:page => params[:page], :per_page => 25)
  end

  def search
    if not params[:number].nil?
      @orders = @current_branch.orders.find(:id=>params[:number]) rescue []
      @orders = @orders.paginate(:page => 1, :per_page => 25)
    elsif not params[:name].nil?
      @orders = @current_branch.orders.where(:name=>params[:name]).paginate(:page => params[:page], :per_page => 25)
    elsif not params[:phone].nil?
      @orders = @current_branch.orders.where(:phone=>params[:phone]).paginate(:page => params[:page], :per_page => 25)
    else
      @orders = [].paginate(:page => 1, :per_page => 25)
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  def export_order
    unless params[:order_ids]
      flash[:error] = "请选择您要导出的订单！"
      redirect_to :back
    else
      @orders = @current_branch.orders.find(params[:order_ids])
      respond_to do |format|
        format.csv { send_data Order.to_csv(@orders, col_sep: ",") }
      end
    end
  end

  def batch_change_state
    to_state = params[:to_state]
    order_ids = params[:order_ids]
    errors = []
    if new_state = params[:state].present? && order_ids = params[:order_ids].present?
      orders = @current_branch.orders.find(params[:order_ids])
      orders.each do |order|
        if order.allow_change_state_for_admin?.include?(to_state.to_i)
          unless order.update_attributes(state: to_state)
            errors << "订单#{order.id}状态更新失败"
          end
        else
          errors << "订单#{order.id}不能修改为当前状态"
        end
      end
    else
      errors <<  "请选择要修改状态的订单！"
    end
    unless errors.present?
      flash[:notice] = "批量修改成功！"
    else
      flash[:error] = errors
    end
    redirect_to backend_shop_branch_orders_path(@current_shop, @current_branch, state: params[:state])
  end

  def change_state
    new_state = params[:state]
    unless new_state.nil?
      new_state = new_state.to_i
      if @order.allow_change_state_for_admin?.include?(new_state)
        if @order.update_attributes(state: new_state)
          redirect_to backend_shop_branch_orders_path(@current_shop, @current_branch, state: new_state), notice: "订单#{@order.id}状态更新成功"
          return
        else
          flash[:error] =  "订单#{@order.id}状态更新失败"
        end
      end
    end
    redirect_to backend_shop_branch_orders_path(@current_shop, @current_branch)
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to backend_shop_branch_order_path(@current_shop.slug, @current_branch, @order), notice: t('Order was successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = @current_shop.orders.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:name, :phone, :address, :note, :delivery_time, :state, :order_type, :desk_no, :guest_num, :arrive_time, :validation_code, :pay_type, :number)
  end


end
