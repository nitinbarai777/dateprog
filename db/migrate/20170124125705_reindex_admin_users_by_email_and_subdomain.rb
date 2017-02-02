class ReindexAdminUsersByEmailAndSubdomain < ActiveRecord::Migration
  def change
    add_index :admin_users, :subdomain, :unique => true
  end
end
