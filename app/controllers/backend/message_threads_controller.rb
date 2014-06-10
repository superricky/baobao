class Backend::MessageThreadsController < BackendApplicationController
  before_action :set_message_thread, only: [:destroy]

  # GET /message_threads
  # GET /message_threads.json
  def index
    @q = @current_shop.message_threads.order('last_update_time').search(params[:q])
    @message_threads = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 25)
  end

  def search
    index
    render "index"
  end


  # DELETE /message_threads/1
  # DELETE /message_threads/1.json
  def destroy
    @message_thread.destroy
    respond_to do |format|
      format.html { redirect_to message_threads_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message_thread
      @message_thread = @current_shop.message_threads.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_thread_params
      params.require(:message_thread).permit(:last_update_time, :user_id, :shop_id)
    end
end
