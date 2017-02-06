class MessagesController < ApplicationController
  
  layout "girl" 
  before_action :authenticate_user!
  
=begin
  # fetch latest chat messages  
  before_action do 
    fetch_messages 1
  end 
=end
  
    
  def create
      #battery_charge_discharge(current_user, "send_message")
      body = params[:message][:body]
      body = body.gsub(/(?:f|ht)tps?:\/[^\s]+/, t("link_removed")).gsub(/<script.*?>[\s\S]*<\/script>/i, "").gsub(/<("[^"]*"|'[^']*'|[^'">])*>/, "")
      params[:message][:sender_id] = current_user.id
      @sender_message = @message = Message.create(message_params)
      @sender = @sender_message.sender
      google_analytics("chat", "send")
      google_analytics("chat", "receive", @message.recipient)
  end
  
  def show_messages
    if params[:profile_request].present?
      request_profile
    elsif params[:profile_allow].present?
      allow_profile
    end    
    google_analytics("chat", "open")
    fetch_recipient_messages 1, params[:recipient_id]
    
    respond_to do |format|
      format.html { render :nothing => true, :layout => ! request.xhr? }
      format.js {}
    end
  end

  def mobile_show_messages
    if params[:profile_request].present?
      request_profile
    elsif params[:profile_allow].present?
      allow_profile
    end    
    google_analytics("chat", "open")
    fetch_messages 1
    fetch_recipient_messages 1, params[:recipient_id]    
  end

  #fetch chat users
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
  
  def show_next_messages
    fetch_recipient_messages params[:page], params[:recipient_id]
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
  
  def close_chat_window
      google_analytics("chat", "close")
      if session[:chats].present?
        chats_hash = JSON.parse(session[:chats])
        chats_hash.delete(params[:recipient_id])
        session[:chats] = chats_hash.to_json
      end
      render :nothing => true
  end
  
  def chat_room
    @sender_message = Message.find(params[:message_id])
    @sender = @sender_message.sender
    fetch_recipient_messages 1, @sender.id
  end
  
  #request to show private profile
  def request_profile
    google_analytics("profile-private", "access-requested")
    #battery_charge_discharge(current_user, "request_private_profile")
    user = User.find_by_id params[:recipient_id]
    profile_access = ProfileAccess.find_by_from_and_to(current_user.id, user.id)
    unless profile_access
      profile_access = ProfileAccess.create(:from => current_user.id, :to => user.id)
      message = Message.create(:sender_id => current_user.id, :recipient_id => user.id, :body => t("allow_request_msg_body", user: current_user.name, user_id: current_user.id, parameter: request.subdomain), :system_message => true)
      message = Message.create(:sender_id => user.id, :recipient_id => current_user.id, :body => t("you_have_requested_to_view_private_profile"), :system_message => true)
    end
  end  
  
  #allow to view private profile
  def allow_profile
    user = User.find_by_id params[:recipient_id]
    profile_access = ProfileAccess.find_by_from_and_to(user.id, current_user.id)
    
    unless profile_access
      profile_access = ProfileAccess.create(:from => user.id, :to => current_user.id, :allow => true)
      
      #increase battery
      #battery_charge_discharge(current_user, "private_part")
      
      google_analytics("profile-private", "access-allowed")
      message = Message.create(:sender_id => current_user.id, :recipient_id => user.id, :body => t("accept_request_msg_body", user: current_user.name, user_id: current_user.id, parameter: request.subdomain), :system_message => true)
      google_analytics("chat", "system-message", message.recipient)       

      # duplicate message to the user himself
      message = Message.create(:sender_id => user.id, :recipient_id => current_user.id, :body => t("accept_request_msg_body", user: current_user.name, user_id: current_user.id, parameter: request.subdomain), :system_message => true)
      google_analytics("chat", "system-message", message.recipient)       

      #AllowProfileWorker.perform_async(profile_access)
      @allow = true
    else
      if profile_access.allow
        profile_access.delete
        #profile_access.update_attributes(:allow => false)
        @allow = false
      else
        profile_access.update_attributes(:allow => true)
        
        #increase battery
        #battery_charge_discharge(current_user, "private_part")
        
        google_analytics("profile-private", "access-allowed")
        message = Message.create(:sender_id => current_user.id, :recipient_id => user.id, :body => t("accept_request_msg_body", user: current_user.name, user_id: current_user.id, parameter: request.subdomain), :system_message => true)
        google_analytics("chat", "system-message", message.recipient)        

        # send the duplicated message to himself
        message = Message.create(:sender_id => user.id, :recipient_id => current_user.id, :body => t("accept_request_msg_body", user: current_user.name, user_id: current_user.id, parameter: request.subdomain), :system_message => true)
        google_analytics("chat", "system-message", message.recipient)        
        
        @allow = true  
      end
    end
  end  
  
  def destroy
    message = Message.find(params[:id])
    message.destroy
  end
  
  private

  def message_params
    params.require(:message).permit!
  end
  
end
