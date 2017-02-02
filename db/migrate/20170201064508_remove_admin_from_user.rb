class RemoveAdminFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :admin_user_id, :integer
  end
end
