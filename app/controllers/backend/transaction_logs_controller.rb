class Backend::TransactionLogsController < BackendApplicationController
  before_action :set_transaction_log, only: [:show]

  # GET /transaction_logs
  # GET /transaction_logs.json
  def index
    @transaction_logs = TransactionLog.all
  end

  # GET /transaction_logs/1
  # GET /transaction_logs/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction_log
      @transaction_log = TransactionLog.find(params[:id])
    end
end
