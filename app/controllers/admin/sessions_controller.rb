class Admin::SessionsController < ActiveAdmin::Devise::SessionsController


  def new
    @admin = AdminUser.new
    super
  end

  def create
    if params[:subdomain].present? and params[:subdomain] == 'superv'
      @admin = AdminUser.find_by_email(params[:admin_user][:email])
      if @admin.present?
        if @admin.subdomain == 'superv'
          @admin.save!
        else
          flash[:alert] = "check your subdomain and login again"
          redirect_to admin_login_path
          return false
        end
      end
    else
      @admin = AdminUser.find_by_email(params[:admin_user][:email])
      if @admin.present?
        if @admin.subdomain != 'superv'
          @admin.save!
        else
          flash[:alert] = "check your subdomain and login again"
          redirect_to new_admin_user_session_path
          return false
        end
      end
    end
    super
  end

end