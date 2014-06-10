#encoding:utf-8
include SmsMsgsHelper


class Backend::SmsMsgsController < BackendApplicationController
  before_action :set_sms_msg, only: [:show, :edit, :update, :destroy]

  # GET /sms_msgs
  # GET /sms_msgs.json
  def index

    if @current_shop && @current_branch.nil?
      @q = @current_shop.sms_msgs.search(params[:q])
    else
      @q = @current_branch.sms_msgs.search(params[:q])
    end
    @sms_msgs = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 25)

  end

  def search
    index
    render :index
  end

  # GET /sms_msgs/1
  # GET /sms_msgs/1.json
  def show
  end

  # GET /sms_msgs/new
  def new
    @sms_msg = @current_branch.sms_msgs.build
  end

  # POST /sms_msgs
  # POST /sms_msgs.json
  def create

    begin
    @sms_msg = send_custom_msg(@current_branch, sms_msg_params[:to], sms_msg_params[:body], 1)
    rescue SmsMsgNoFeeException=>e
      @error = e.message
    end

    respond_to do |format|
      if @sms_msg.present?
        format.html { redirect_to backend_shop_branch_sms_msg_path(@current_shop.slug, @current_branch, @sms_msg), notice: '短信成功发送' }
        format.json { render action: 'show', status: :created, location: @sms_msg }
      else
        @sms_msg = @current_branch.sms_msgs.build
        format.html { render action: 'new' }
        format.json { render json: @sms_msg.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sms_msg
      if @current_branch
        @sms_msg = @current_branch.sms_msgs.find(params[:id])
      else
         @sms_msg = @current_shop.sms_msgs.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sms_msg_params
      params.require(:sms_msg).permit(:to, :body, :sms_message_id, :date_created, :msg_type)
    end
end
