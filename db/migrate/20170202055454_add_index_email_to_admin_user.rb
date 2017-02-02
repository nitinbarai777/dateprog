class AddIndexEmailToAdminUser < ActiveRecord::Migration
  def change
    add_index :admin_users, :email
  end
end
