class UsersController < ApplicationController
  
  layout "girl"
  
  before_filter :authenticate_user!
  
  # fetch latest chat messages  
  before_action do 
    fetch_messages 1
  end 

  def index 
  end

  #change password
  def edit
    @user = current_user
  end

  #update password
  def update_password
    google_analytics("user", "password-update")
    @user = User.find(current_user.id)
    if @user.update(user_params)
      # Sign in the user by passing validation in case their password changed
      sign_in @user, :bypass => true
      flash.now[:notice] = t("password_changed_successfully")
    else
      flash.now[:notice] = t("change_password_wrong")
    end
  end
  
  #delete account
  def delete_account
    user = current_user
    case params[:delete_reason]
    when "1"
      reason = t("delete_reason1")
    when "2"
      reason = t("delete_reason2")
    when "3"
      reason = t("delete_reason3")
    when "4"
      reason = "Other: #{params[:reason]}"
    end
    if params[:remove].present?
      google_analytics("user", "delete", "", reason)
      sign_out user
      user.destroy
      redirect_to root_path, notice: t("account_deleted")
    else    
      google_analytics("user", "freeze", "", reason)
      user.update_attributes(:freeze_account => true)
      sign_out user
      redirect_to root_path, notice: t("account_now_deactivated_and_not_visible")
    end
  end
  
  #report abuse
  def report_abuse
    google_analytics("profile-public", "reported-abuse")
    @user = User.find_by_id params[:user_id]
    if @user.present?
      @user.update_attribute(:report_abuse, (@user.report_abuse+1))
      ReportAbuse.find_or_create_by(:from => current_user.id, :to => @user.id)
      if @user.report_abuse > 3
        @user.update_attribute(:is_active, false)
      end
    end  
  end
  
  #request to show private profile
  def request_profile
    google_analytics("profile-private", "access-requested")
    user = User.find_by_id params[:user_id]
    profile_access = ProfileAccess.find_by_from_and_to(current_user.id, user.id)
    @requested = true
    unless profile_access
      @requested = false
      profile_access = ProfileAccess.create(:from => current_user.id, :to => user.id)
      message = Message.create(:sender_id => current_user.id, :recipient_id => user.id, :body => t("allow_request_msg_body", user: current_user.name, user_id: current_user.id, parameter: request.subdomain), :system_message => true) 
      #RequestProfileWorker.perform_async(profile_access)
    end
  end
  
  #show all allowed profiles
  def allowed_private_profile
    google_analytics("profile-private", "show-allowed-private-profile")
    @allowed_profiles = current_user.allowed_from
  end
  
  #allow-disalllow from show listing
  def allow_disallow
    @profile_access = ProfileAccess.find_by_id(params[:id])
    profile_access_allow = @profile_access.allow ? false : true
    if profile_access_allow
      message = Message.create(:sender_id => current_user.id, :recipient_id => @profile_access.allow_from.id, :body => t("accept_request_msg_body", user: current_user.name, user_id: current_user.id, parameter: request.subdomain), :system_message => true)
      google_analytics("chat", "send")
      google_analytics("chat", "system-message", message.recipient)
      google_analytics("profile-private", "access-disallowed")
    else
      google_analytics("profile-private", "access-allowed")
    end
    @profile_access.update_attributes(:allow => profile_access_allow) 
    respond_to do |format|
      format.html { render :nothing => true, :layout => ! request.xhr? }
      format.js {}
    end    
  end
  
  #delete allow from show listing
  def delete_profile_access
    google_analytics("profile-private", "delete-profile-access")
    @profile_access = ProfileAccess.find_by_id(params[:id])
    if @profile_access.present?
      @profile_access.delete
    end
  end

  def read_notifications
    notifications = current_user.view_from.where(:is_read => false)
    if notifications.count > 0
      notifications.update_all(:is_read => true)
    end
    respond_to do |format|
      format.html { render :nothing => true, :layout => ! request.xhr? }
      format.js {}
    end    
  end

  def request_create_course
    current_user.update_attributes(:instructor_request => true)
  end

  def like_dislike
    @recipient = User.find(params[:id])
    @full_profile = params[:full_profile].present? ? params[:full_profile] : false

    if @recipient.liked?(current_user) and !current_user.liked?(@recipient)
      message = Message.create(:sender_id => current_user.id, :recipient_id => @recipient.id, :body => t("user_also_liked_you"), :system_message => true)
      message = Message.create(:sender_id => @recipient.id, :recipient_id => current_user.id, :body => t("user_also_liked_you"), :system_message => true)
      fetch_recipient_messages 1, params[:id]
    end

    current_user.liked?(@recipient) ? current_user.dislikes(@recipient) : current_user.likes(@recipient)

  end

  private

  def user_params
    # NOTE: Using `strong_parameters` gem
    params.required(:user).permit(:password, :password_confirmation)
  end

  def fetch_recipient_messages page, recipient_id
    @message = Message.new
    @recipient = User.find(recipient_id)
    @report_abuse = ReportAbuse.find_by_from_and_to(@recipient.id, current_user.id)
    @existing_chats = {}
    unless @report_abuse.present?
      unread_messages = Message.where("recipient_id = ? and sender_id = ? and is_read = ?", current_user.id, @recipient.id, false).update_all(:is_read => true)
      @messages = current_user.received_or_sent_messages_user(recipient_id).includes(:sender, :recipient).order("id desc").paginate(:per_page => 50,:page => page).reverse
      store_chats_session @recipient
    end  
  end  
  
 # fetch chat messages
  def fetch_messages page
      @message = Message.new
      message_users = current_user.received_sent_messages.includes(:sender, :recipient).order("id desc").group("messages.id, messages.sender_id, messages.recipient_id")
      @message_users_hash = {}
      message_users.each do |message|
        unless message.sender_id == current_user.id
          sender = message.sender
          if sender.present? && sender.is_activated?
            @message_users_hash[message.sender_id] = message.sender unless @message_users_hash[message.sender_id].present?
          end
        end
        unless message.recipient_id == current_user.id
          recipient = message.recipient
          if recipient.present? && recipient.is_activated?
            @message_users_hash[message.recipient_id] = message.recipient unless @message_users_hash[message.recipient_id].present?
          end
        end
      end
  end    
end
