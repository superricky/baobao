include BranchesHelper
class Backend::MessagesController < BackendApplicationController

  # GET /messages
  # GET /messages.json
  def index
    @message_thread = @current_shop.message_threads.find(params[:message_thread_id])
    @messages = @message_thread.messages.paginate(:page => params[:page], :per_page => 25)
  end

  def search
    leave_messages
    render :leave_messages
  end

  def leave_messages
    message_thread_ids = @current_shop.message_threads.map(&:id)
    @q = Message.where(:message_thread_id => message_thread_ids, :is_leave_msg=>true).search(params[:q])
    @messages = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 25)
  end
end
