class Backend::TransactionLogsController < BackendApplicationController
  before_action :set_transaction_log, only: [:show]

  # GET /transaction_logs
  # GET /transaction_logs.json
  def index
    @transaction_logs = TransactionLog.all
  end
end
