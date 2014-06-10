#encoding: utf-8
module WalletLogsHelper
  def get_wallet_log_path(wallet_log)
    @current_branch.present? ? backend_shop_branch_wallet_log_path(@current_shop.slug, @current_branch, wallet_log) :
          backend_shop_wallet_log_path(@current_shop.slug, wallet_log)
  end

  def get_wallet_logs_path
    @current_branch.present? ? backend_shop_branch_wallet_logs_path(@current_shop.slug, @current_branch) :
          backend_shop_wallet_logs_path(@current_shop.slug)
  end

  def get_wallet_logs_type_array
    [
      ["全部类型", ""],
      [get_wallet_logs_type_name(WalletLog::WALLET_LOG_TYPE_RECHARGE), WalletLog::WALLET_LOG_TYPE_RECHARGE],
      [get_wallet_logs_type_name(WalletLog::WALLET_LOG_TYPE_RECHARGE_ROLLBACK), WalletLog::WALLET_LOG_TYPE_RECHARGE_ROLLBACK],
      [get_wallet_logs_type_name(WalletLog::WALLET_LOG_TYPE_PAY), WalletLog::WALLET_LOG_TYPE_PAY],
      [get_wallet_logs_type_name(WalletLog::WALLET_LOG_TYPE_ROLLBACK), WalletLog::WALLET_LOG_TYPE_ROLLBACK],
      [get_wallet_logs_type_name(WalletLog::WALLET_LOG_TYPE_SUCCESS), WalletLog::WALLET_LOG_TYPE_SUCCESS]
    ]
  end

  def get_wallet_logs_type_name(wallet_log_type)
    I18n.t "activerecord.attributes.wallet_log.wallet_log_types.#{wallet_log_type}"
  end
end
