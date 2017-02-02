class SessionsController < Devise::SessionsController

 require 'net/http'
 
 REGISTER_POINTS = 1000
 REGISTER_BATTERY_SIZE = 1000 
  
  before_filter :set_locale
  skip_before_filter :verify_authenticity_token, :only => [:sign_with_social]
  
  #singin-singup form
  def new   
    @user = User.new
    @admin = AdminUser.find_by subdomain: request.subdomain
    super
  end

  #signin-signup
  def create
    if params[:user].present?
       params[:user][:password_confirmation] = params[:user][:password]
       # user = @admin.users.where(:email => params[:user][:email]).first

       # raise user.inspect
       
       user = User.find_by_email(params[:user][:email])
       @user = User.new
       
      # sign in
      if params[:sign_in]
        email = params[:user][:email].split("@")
        @admin = AdminUser.find_by subdomain: request.subdomain

        user = @admin.users.find_by_email(user.email)

          if email.present? && email[1].present? && $domain_black_list.include?(email[1])
            flash.now[:notice] = t("email_address_is_not_allow")
            render :new
          else
            #session[:advertise] = true
            if user.present?
              if user.freeze_account
                user.update_attributes(:freeze_account => false)
              end
              user.update_attributes(:locale => I18n.locale)
              google_analytics("user", "login", user)
              flash.now[:notice] = "signed in successfully" # todo: replace with t()
            else
              flash.now[:notice] = t("check_subdomain")
              redirect_to destroy_user_session_path,notice: t("check_subdomain")
              return false
            end

            super
          end
      else
        # signing up
        if params[:user][:email].present?
          email = params[:user][:email].split("@")
          if email.present? && email[1].present? && ($domain_black_list.include?(email[1]) || duplicate_email(params[:user][:email]))
            flash.now[:notice] = t("email_address_is_not_allow")
            render :new
          else
            @user = params[:user][:email].present? ? User.find_by_email(params[:user][:email]) : nil
            if !@user.nil? 
              flash.now[:notice] = t("account_already_exists")
              render :new
              return false
            end
          
            @user = User.new(user_params)
            @admin = AdminUser.find_by subdomain: request.subdomain
            @user.adminuser_users.build(:admin_user_id => @admin.id)
            if @user.save
              referral_code = "#{@user.id}#{SecureRandom.hex(10)}"
              @user.update_attributes(:points => REGISTER_POINTS, :referral_code => referral_code, :battery_size => REGISTER_BATTERY_SIZE)
              flash[:notice] = t("sign_up_success")
              if session[:referral_code].present?
                referred_user = User.find_by_referral_code(session[:referral_code])
                if referred_user.present?
                  #increase battery
                  #battery_charge_discharge(referred_user, "invite")
                  @user.update_attributes(:referred_user_id => referred_user.id)
                  session[:referral_code] = nil
                end
                google_analytics("user", "new-referred", @user)
              else
                google_analytics("user", "new", @user)
              end
              redirect_to new_user_session_path(:sign_up => "sign_up")
            else
              flash.now[:notice] = t("wrong_with_signup")
              render :new
            end
          end
        else
          flash.now[:notice] = t("wrong_with_signup")
          render :new
        end
      end  
    end
    
  end

  #logout from service
  def destroy
    if current_user.present?
      current_user.update_attributes(:last_sign_out_at => Time.now.utc)
      google_analytics("user", "logout")
    end
    super
  end  
  
  #signin-signup with social networks
  def sign_with_social
    redirect_to '/'
=begin    
    token = params[:token] # We get the token from the request
    
    if !token.nil?
      # Execute remote query on site ulogin
      require 'net/http'
      url = URI.parse('https://ulogin.ru/token.php?token='+token)
      # Parse the data
      social_data = ActiveSupport::JSON.decode(Net::HTTP.get(url))
      
      if Rails.env.development?
        puts '--------------------------------------------socialdata'
        puts social_data.inspect
        puts '--------------------------------------------socialdata'
      end 
      
      identity = social_data['identity']
      uid = social_data['uid']
      email = social_data['email']
      city = social_data['city']
      country = social_data['country']
      avatar = social_data['avatar']
      first_name = social_data['first_name']
      last_name = social_data['last_name']
      provider = social_data["network"]
      
      # Search By email
      user = User.find_by_email(email)



      if user.nil?
      	arr_email = email.split("@") if email.present?
      	if arr_email.present? && arr_email[1].present? && $domain_black_list.include?(arr_email[1])
        	flash[:notice] = t("email_address_is_not_allow")
        else
          secure_pass = SecureRandom.hex(10)
          user = User.new
          user.email = email ? email :  "#{uid}@dateprog.com"
          user.password = secure_pass
          user.password_confirmation = secure_pass
          user.username = "#{first_name} #{last_name}"
          user.city = city
          user.country = country
          user.points = REGISTER_POINTS
          user.battery_size = REGISTER_BATTERY_SIZE
          user.skip_confirmation! # Needs to confirmation message authentication is expelled via email
          user.save
          
          referral_code = "#{user.id}#{SecureRandom.hex(10)}"
          user.update_attributes(:referral_code => referral_code)
          
          unless user.nil?
            auth_provider = AuthenticationProvider.find_by_name(provider)
            auth_provider = AuthenticationProvider.create(:name => provider) unless auth_provider.present?
            UserAuthentication.find_or_create_by(:uid => uid, :user_id => user.id, :token => params[:token], :authentication_provider_id => auth_provider.id)
          end
            
          sign_in user, :bypass => true
          user.update_attributes(:last_sign_in_at => Time.now.utc)
        end
      else

        user_auth = UserAuthentication.find_by_uid(uid)
        if user_auth.nil?
          auth_provider = AuthenticationProvider.find_by_name(provider)
          auth_provider = AuthenticationProvider.create(:name => provider) unless auth_provider.present?
          UserAuthentication.find_or_create_by(:uid => uid, :user_id => user.id, :token => params[:token], :authentication_provider_id => auth_provider.id)
        end
        sign_in user, :bypass => true
        user.update_attributes(:last_sign_in_at => Time.now.utc, :locale => I18n.locale)
      end
      
    end
     
    if current_user || user.present?
      flash[:notice] = t("sign_in_with", provider: provider)
    end
    redirect_to root_path, :notice => flash[:notice]    
=end    
  end  
  
  #invitation confirmation
  def invitation_confirmation
    redirect_to '/'
=begin    
    user = User.find_by_email(params[:email])
    if user
      sign_in user, :bypass => true
      user.update_attributes(:last_sign_in_at => Time.now.utc)
      redirect_to  girls_path, notice: t("welcome_to_dateprog")
    else
      redirect_to root_path
    end
=end    
  end

  #notification confirmation
  def notification_confirmation
    user = User.find_by_notification_token(params[:notification_token])
    if user
      case params[:sign_in]
      when "yes"
        sign_in user, :bypass => true
        user.update_attributes(:last_sign_in_at => Time.now.utc)
        google_analytics("user", "login-via-mail", user)

        if params[:profile]
          recipient = User.find_by_id(params[:profile].to_i)
          store_chats_session recipient
          if mobile_or_tablet_request?
            redirect_to mobile_show_messages_path(params[:profile].to_i, :message_id => '', :chat => "yes")
          else
            redirect_to profile_show_path(params[:profile].to_i)
          end
        else
          redirect_to girls_path, notice: t("welcome_to_dateprog")
        end

      when "no"
        session[:email] = user.email
       redirect_to new_user_session_path(:sign_in => "true")
      when "stop"
        user.update_attributes(:notification => false)
        redirect_to new_user_session_path(:sign_in => "true"), :notice => t("you_have_inactivated_notifications")
      else
        redirect_to root_path, :notice => t("invalid_url")
      end
    else  
      redirect_to root_path, :notice => t("invalid_url")
    end
  end  

  #invitation referral signup
  def invitation_signup
    redirect_to '/'
=begin    
    if params[:referral_code].present?
      user = User.find_by_referral_code(params[:referral_code])
      if user.present?
        session[:referral_code] = params[:referral_code]
      end
    end
    redirect_to new_user_session_path
=end    
  end
  
  
  private 
  
  def user_params
    params.require(:user).permit!
  end    

  def duplicate_email email
    email = email.split("@")
    if email[1] == "gmail.com" && email[0].include?("+")
      return true
    end
    return false
  end
  
end