#encoding: utf-8
class Backend::CurrencySymbolsController < BackendApplicationController

  def index
    @currency_symbols =@current_shop.currency_symbols
  end

  def new
    @currency_symbol = @current_shop.currency_symbols.new
  end

  def edit
    @currency_symbol =@current_shop.currency_symbols.find(params[:id])
  end

  def update
    @currency_symbol = @current_shop.currency_symbols.find(params[:id])
    if @currency_symbol.update_attributes(currency_symbol_params)
      redirect_to backend_shop_currency_symbols_path(@current_shop.slug), notice: "更新货币类型成功！"
    else
      render "edit"
    end
  end

  def destroy
    @currency_symbol =@current_shop.currency_symbols.find(params[:id])
    @currency_symbol.destroy
    redirect_to backend_shop_currency_symbols_path(@current_shop.slug), notice: "删除货币类型成功！"
  end

  def create
    @currency_symbol = @current_shop.currency_symbols.build(currency_symbol_params)
    if @currency_symbol.save
      redirect_to backend_shop_currency_symbols_path(@current_shop.slug), notice: "创建货币类型成功！"
    else
      render "new"
    end
  end

  private

    def currency_symbol_params
      params.require(:currency_symbol).permit(:symbol, :decoration)
    end
end