class AddUserIdToWalletLogs < ActiveRecord::Migration
  def change
    add_column :wallet_logs, :user_id, :integer
    add_index :wallet_logs, :user_id
  end
end
