class AddColumnSubdomainToAdminUser < ActiveRecord::Migration
  def change
    add_column :admin_users , :subdomain , :string
  end
end
