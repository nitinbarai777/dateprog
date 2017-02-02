class CreateAdminuserUsers < ActiveRecord::Migration
  def change
    create_table :adminuser_users do |t|
      t.references :admin_user, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
