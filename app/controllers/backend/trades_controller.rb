class Backend::TradesController < BackendApplicationController
  def index
    unless @current_branch.present?
      @q = @current_shop.trades.search(params[:q])
      @trades = @q.result(distinct: true).paginate(page: params[:page], :per_page => 50)
    else
      @q = @current_branch.trades.search(params[:q])
      @trades = @q.result(distinct: true).paginate(page: params[:page], :per_page => 50)
    end
  end

  def show
    unless @current_branch.present?
      @trade = @current_shop.trades.find(params[:id])
    else
      @trade = @current_branch.trades.find(params[:id])
    end
  end

  private
  def trade_params
    params.require(:trade)
  end
end
