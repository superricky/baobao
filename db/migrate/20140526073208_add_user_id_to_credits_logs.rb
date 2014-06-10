class AddUserIdToCreditsLogs < ActiveRecord::Migration
  def change
    add_column :credits_logs, :user_id, :integer
    add_index :credits_logs, :user_id
  end
end
