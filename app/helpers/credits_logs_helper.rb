module CreditsLogsHelper
  def get_credits_log_path(credits_log)
    @current_branch.present? ? backend_shop_branch_credits_log_path(@current_shop.slug, @current_branch, credits_log) :
          backend_shop_credits_log_path(@current_shop.slug, credits_log)
  end

  def get_credits_logs_path
    @current_branch.present? ? backend_shop_branch_credits_logs_path(@current_shop.slug, @current_branch) :
          backend_shop_credits_logs_path(@current_shop.slug)
  end

  def get_credits_log_type_array
    [
     ["全部", ""],
     [CreditsLog::CREDITS_LOG_TYPE_RECHARGE_NAME, CreditsLog::CREDITS_LOG_TYPE_RECHARGE],
     [CreditsLog::CREDITS_LOG_TYPE_CONSUME_NAME, CreditsLog::CREDITS_LOG_TYPE_CONSUME],
     [CreditsLog::CREDITS_LOG_TYPE_CONSUME_ROLLBACK_NAME, CreditsLog::CREDITS_LOG_TYPE_CONSUME_ROLLBACK],
     [CreditsLog::CREDITS_LOG_TYPE_PAY_NAME, CreditsLog::CREDITS_LOG_TYPE_PAY],
     [CreditsLog::CREDITS_LOG_TYPE_PAY_ROLLBACK_NAME, CreditsLog::CREDITS_LOG_TYPE_PAY_ROLLBACK],
     [CreditsLog::CREDITS_LOG_TYPE_PAY_SUCCESS_NAME, CreditsLog::CREDITS_LOG_TYPE_PAY_SUCCESS],
     [CreditsLog::CREDITS_LOG_TYPE_FOLLOW_NAME, CreditsLog::CREDITS_LOG_TYPE_FOLLOW]
    ]
  end

  def get_branch_name_array
    branch_names = [["全部", ""]]
    branch_names += @current_shop.branches.map{|branch| [branch.name, branch.name]}
  end
end
