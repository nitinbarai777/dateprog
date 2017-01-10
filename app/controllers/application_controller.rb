class ApplicationController < ActionController::Base

  MALE = 1
  FEMALE = 2  

  include Mobu::DetectMobile

  include ApplicationHelper 

  include AjaxHelper

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery
  before_filter :set_locale, :unread_messages
  before_action :configure_permitted_parameters, if: :devise_controller?
  #before_filter :battery_charge_every_minute

  after_filter :user_activity
  
  #before_filter :cors_preflight_check
  #after_filter :cors_set_access_control_headers  
    
  LOCALE_LANG = ["en", "ru"]
  
  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = FAYE_URL
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = FAYE_URL
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end
  
  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = FAYE_URL
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
      headers['Access-Control-Request-Method'] = FAYE_URL
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      render :text => '', :content_type => 'text/plain'
    end
  end

  def google_analytics(category, action, user='', label='')
    if Rails.env.production?
    gabba = Gabba::Gabba.new(ENV["GOOGLE_ANALYTIC_UA_CODE"], ENV["GOOGLE_ANALYTIC_DOMAIN_NAME"], request.user_agent)
      user = user.present? ? user : current_user
      if user.present?
        gabba.set_custom_var(1, 'dimension1', user.referral_code, Gabba::Gabba::VISITOR)
        if user.is_girl
          gabba.set_custom_var(2, 'dimension2', 'Female', Gabba::Gabba::VISITOR)
        else
          gabba.set_custom_var(2, 'dimension2', 'Male', Gabba::Gabba::VISITOR)
        end
        if user.confirmed_at.present?
          usage_days = (Date.today - user.confirmed_at.to_date).to_i
        else
          usage_days = 0
        end
        gabba.set_custom_var(3, 'dimension3',usage_days.to_s, Gabba::Gabba::VISITOR)

        category_action = "#{category}:#{action}"
        mixpanel_tracker(category_action, user)
      end
      gabba.identify_user(cookies[:__utma], cookies[:__utmz])
      gabba.event(category, action, label, "", true)
    end
  end

  def mixpanel_tracker(category, user)
    if user.present?
      tracker = Mixpanel::Tracker.new(ENV["MIXPANEL_TOKEN"])
      tracker.track(user.referral_code, category)
      looking_for = user.looking_for == MALE ? "Male" : "Female"
      gender = user.gender == MALE ? "Male" : "Female"
      skill_name = "None"
      if user.skill
        skill_name = user.skill.name
      end
      tracker.people.set(user.referral_code, {
          'Profile ID'  => user.id,
          'ip'             => request.remote_ip,
          'Username'       => user.username,
          'Email'            => user.email,
          'Age'            => user.age,
          'City'            => user.city,
          'Country'            => user.country_name,
          'Looking For'            => looking_for,
          'Gender'            => gender,
          'Skill'  => skill_name,
      });
      # increase the counter (evenName-Count)
      tracker.people.increment(user.referral_code, { category + '-Count' => "1"} )
    end
  end

  def store_chats_session recipient
  	if recipient.present? && current_user.present?
      recipient_name = recipient.name
      if mobile_or_tablet_request?
        session[:chats] = {recipient.id => recipient_name}.to_json
      else
  	    if session[:chats].present?
  	      @existing_chats = JSON.parse(session[:chats])
  	      chats_hash = {}
  	      chats_hash = @existing_chats
  	      chats_hash[recipient.id] = recipient_name
  	      unread_messages = Message.where("recipient_id = ? and sender_id = ? and is_read = ?", current_user.id, recipient.id, false).update_all(:is_read => true)
  	      session[:chats] = chats_hash.to_json
  	    else
  	      session[:chats] = {recipient.id => recipient_name}.to_json
  	    end
      end
	  end
  end  

  # optional admin access check to optionally permit white list users only
  def access_denied
    if Rails.env == 'production'
      #whitelist = [].freeze # whitelist to access the panel
      ip_arr = request.remote_ip.to_s.split(".")
      # remove last to ip parts to get like 255.255
      ip_arr.pop 
      ip_arr.pop
      request_remote_ip = ip_arr.join(".")
      
      logger.info "Admin area accessed from:" + request_remote_ip.to_s
      
      # optional white list protection to disallow access to the admin area
=begin      
      whitelist = [].freeze
      unless whitelist.include? request_remote_ip
        logger.warn "Admin area access denied to:" + request_remote_ip.to_s
        redirect_to "/", :notice => t("access_denied")
      end
=end      
    end
  end

  def matching_ratio_girls girls, girls_limit
    girls_hash = {} 
    temp_hash = {}
    ratio_hash = {}
    girls_id_arr = []
    i = 0
    girls.each_with_index do |girl, k|
      unless girls_id_arr.include? girl.id
        temp_hash[k] = girl
        if girl.is_girl
          ratio_hash[k] = matching_ratio_girl(current_user, girl)
        else
          ratio_hash[k] = matching_ratio_programmer(current_user, girl)
        end  
        girls_id_arr << girl.id
        i = i + 1
      end
    end
    ratio_hash = Hash[ratio_hash.sort_by{|k, v| v}.reverse]
    ratio_hash.each do |k, v|
      girls_hash[k] = temp_hash[k] 
    end  
    return [girls_hash, ratio_hash]
  end
  
  
  private
  
  def matching_ratio_girl programmer, girl
    programmer_skill_traits = programmer.skill.skill_traits.includes(:skill, :trait).collect { |skill_trait| skill_trait.trait.name }
    if girl.traits.present?
      girl_traits = ActiveSupport::JSON.decode(girl.traits)
      traits = Trait.all
      result_hash = 0
      for n in 0..traits.count-1
        if programmer_skill_traits.include? girl_traits["#{n}"]
          result_hash = result_hash + 1
        end
      end
      (result_hash*100)/17
    else
      0  
    end  
  end  
  
  def matching_ratio_programmer programmer, girl
    if programmer.skill_id == girl.skill_id
      100
    else
      result_hash = 1
      girl_skill_traits = girl.skill.skill_traits.includes(:skill, :trait).collect { |skill_trait| skill_trait.trait.name }
      programmer_skill_traits = programmer.skill.skill_traits.includes(:skill, :trait).collect { |skill_trait| skill_trait.trait.name }
      girl_skill_traits.each do |skill|
        if programmer_skill_traits.include? skill
          result_hash = result_hash + 1
        end
      end
      (result_hash*100)/23
    end    
  end
  
  def set_lang_cookie
    # set language cookie using query string parameter 'lang'
    if params[:locale]
      if LOCALE_LANG.include?(params[:locale])
        session[:lang] = params[:locale]
        current_user.update_attributes(:locale => params[:locale]) if current_user
      end
    end
  end
  
  def set_locale
    set_lang_cookie
    begin
      I18n.locale = session[:lang] || params[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
    rescue
      I18n.locale = I18n.default_locale
    end
    unless LOCALE_LANG.include?(I18n.locale.to_s)
      I18n.locale = I18n.default_locale
    end
    @language = Language.find_by_code(I18n.locale)
    @invite = Invite.new
  end
  
  def set_admin_locale
    set_lang_cookie
    begin
      I18n.locale = session[:lang] || params[:locale] || extract_locale_from_accept_language_header || I18n.default_locale
    rescue
      I18n.locale = I18n.default_locale
    end
    unless LOCALE_LANG.include?(I18n.locale.to_s)
      I18n.locale = I18n.default_locale
    end
  end  
  
  def extract_locale_from_accept_language_header
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first if request.env['HTTP_ACCEPT_LANGUAGE']
  end
  
  def authenticate_girl!
    redirect_to root_path unless current_user.is_girl
  end
  
  def authenticate_programmer!
    redirect_to root_path if current_user.is_girl
  end
  
  def unread_messages
    if current_user
      @unread_messages_hash = {}
      unread_messages = Message.includes(:sender).select("count(sender_id) as total, sender_id").group("sender_id").where("is_read = ? and recipient_id = ?", false, current_user.id)
      #unread_messages = Message.group("sender_id, id").where("is_read = ? and recipient_id = ?", false, current_user.id).count("sender_id")
      
      unread_messages.each do |unread_message|
        unread_message
        if unread_message.sender.present?
        	@unread_messages_hash[unread_message.sender_id] = [unread_message.sender.name, unread_message.total]
        end
      end
      @unread_message_count = @unread_messages_hash.size
    end
  end
  
  def battery_charge_every_minute
    if current_user
      user_points = current_user.points
      user_battery_size = current_user.battery_size
      if (Time.now.utc > current_user.battery_date + 1.minutes)
        minutes = (((Time.now.utc - current_user.battery_date).to_i.abs)/60).to_i
        user_battery_size = user_battery_size + (minutes*20)
        user_battery_size = user_battery_size > user_points ? user_points : user_battery_size
        current_user.update_attributes(:battery_date => Time.now.utc, :battery_size => user_battery_size.to_i, :points => user_points.to_i)
      end
    end
  end
  
  def battery_charge_discharge(user, actionBattery='')
    #points - battery capacity, battery_size - battery charge 
    pointsMax = 3000
    case actionBattery
    when "invite"
      user_points = user.points + 200
      user_battery_size = user.battery_size + 200
    when "pass_test"
      user_points = user.points + 200
      user_battery_size = user.battery_size + 200
    when "private_part"
      user_points = user.points + 0
      user_battery_size = user.battery_size + 50
    when "upload_avatar"
      user_points = user.points + 50
      user_battery_size = user.battery_size + 50
    when "send_message"
      user_points = user.points
      user_battery_size = user.battery_size - 1
    when "view_profile"
      user_points = user.points
      user_battery_size = user.battery_size - 1
    when "request_private_profile"
      user_points = user.points
      user_battery_size = user.battery_size - 1
    when "apply_filter"
      user_points = user.points
      user_battery_size = user.battery_size - 1
    end
    
    user_points = user_points > pointsMax ? pointsMax : user_points
    user_points = user_points < 0 ? 0 : user_points
    
    user_battery_size = user_battery_size > user_points ? user_points : user_battery_size
    user_battery_size = user_battery_size < 0 ? 0 : user_battery_size
    
    user.update_attributes(:battery_size => user_battery_size.to_i, :points => user_points.to_i)
  end


  def user_activity
    #current_user.try :touch
    current_user.update_attributes(:current_sign_in_at => Time.now.utc) if current_user
  end  

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update) do |params|
      params.permit(
        :email, :password, :password_confirmation, :username,:current_password,
        :age, :city, :country, :avatar
      )
    end
  end

end
