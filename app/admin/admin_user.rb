ActiveAdmin.register AdminUser do

  menu :if => proc { current_admin_user.has_role?(:superadmin)}

  includes :roles

  permit_params :email, :password, :password_confirmation, :subdomain,
  adminuser_users_attributes: [:id, :admin_user_id, :user_id, :_destroy]

  index do
    selectable_column
    id_column
    column :email
    column :subdomain
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    tabs do
      tab "Details" do
        attributes_table_for admin_user do
            row :id
            row :email
            row :subdomain
        end
      end

      tab "Associations" do
        panel "Users" do
          table_for admin_user.users do
            column :id
            column :username
            column :email
            column :is_girl
            column :is_instructor
            column :is_active
            column :freeze_account
          end
        end
      end
    end
  end

  filter :email
  filter :subdomain
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.semantic_errors *f.object.errors.keys
      tabs do
        tab "Details" do

          f.inputs "Admin Details" do
            f.input :email
            f.input :password
            f.input :password_confirmation
            f.input :subdomain

          end
        end
        tab "Add User" do
          f.inputs "Users" do
            f.has_many :adminuser_users, new_record: "Add a User", allow_destroy: true do |ff|
               ff.semantic_errors *ff.object.errors.keys
               ff.input :user_id, as: :select, :collection => User.all.map{|u| [u.username,u.id]}, include_blank: false
            end
          end
        end
      end
    f.actions
  end

end
