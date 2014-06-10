class Backend::PrintersController < BackendApplicationController

  before_action :set_printer, only: [:edit, :update, :show, :destroy]


  def edit
  end

  def new
    @printer = @current_branch.printers.build
  end

  def create
    @printer = @current_branch.printers.build(printer_params)
    respond_to do |format|
      if @printer.save
        format.html { redirect_to backend_shop_branch_printer_path(@current_shop.slug, @current_branch, @printer), notice: t('Printer has successfully created.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @printer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @printer.update(printer_params)
        format.html { redirect_to backend_shop_branch_printer_path(@current_shop.slug, @current_branch, @printer), notice: t('Printer has successfully updated.') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @printer.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @printers = @current_branch.printers
  end

  def show
  end
  #/DELETE
  def destroy
    @printer.destroy
    respond_to do |format|
      format.html { redirect_to backend_shop_branch_printers_url }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_printer
      @printer = @current_branch.printers.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def printer_params
      params.require(:printer).permit(:name, :memberCode, :deviceNo, :apiKey, :print_on_order, :copy_count, :printer_type, :phone)
    end
end
