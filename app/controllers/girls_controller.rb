class GirlsController < ApplicationController

  layout "girl"

  autocomplete :tag, :name, :full => true, :display_value => :funky_method

  before_action :authenticate_user!
  
  # fetch latest chat messages  
  before_action do 
    fetch_messages 1
  end  
  

  def index
    @dashboard = "active"
    @admin = AdminUser.find_by subdomain: request.subdomain
    @users = []
    user_detail = current_user.user_detail
    @user_detail = user_detail.present? ? user_detail : UserDetail.new
    @received_messages_count = current_user.received_messages.count
    @filter_values = ActiveSupport::JSON.decode(current_user.filter) if current_user.filter.present?
    current_user.is_girl ? girls_index : programmers_index
    advertise_show

    # same as in courses_controller#fetch_courses
    # display list of latest approved courses
    @all_courses = Course.approved.where(:instructor_id => @admin.users.map(&:id)).paginate(:per_page => 12, :page => params[:page])

    # raise @all_courses.first.avatar.url(:medium).inspect
    #@courses = Course.published
  end

  def girls_index
=begin    
    if params[:search].present? or !current_user.traits.present?
      #google_analytics("dashboard", "new")
      traits = Trait.all.collect { |trait| trait.name }
      traits_count = traits.count
      @trait_hash = {}
      if params[:search].present?
        if traits_count > 0
          traits_count = traits_count.even? ? (traits_count/2) : ((traits_count - 1)/2)
          j = 0
          k = 0
          for i in 0..(traits_count-1)
              @trait_hash[j] = [traits[k], traits[k+1]]
              j = j + 1
              k = k + 2
          end
        end
      end
    else
      #google_analytics("dashboard", "view")
      @message = Message.new
      fetch_users 1
    end
=end    
    @message = Message.new
    fetch_users 1
  end

  def programmers_index
      #google_analytics("dashboard", "view")
      @message = Message.new
      #fetch_users 1 if current_user.profile_completed? && current_user.skill.present?
      fetch_users 1 if current_user.profile_completed? 
  end
  
  def show_profile
    if request.xhr? 
      @user = User.find_by_id(params[:id])
      # logger.info "rendering ajax profile for user #" + @user.id.to_s
      #tips
      @tips = @language.tips.includes(:language).where(:for_girl => false).map(&:content) if current_user.gender == 1
      @chat = true
      # show close button for ajax requested inline page
      @close_btn_visible= true
      @close_btn_target = "#portfolio" + @user.id.to_s
    else
      redirect_to :action => :profile_show
    end 
  end

  def next_users
    # commented out results-more logging as it creates too much noise
    # google_analytics("dashboard", "results-more")
    @message = Message.new
    fetch_users params[:page]
  end

  def fetch_users page=''
      filter_values = ActiveSupport::JSON.decode(current_user.filter) if current_user.filter.present?
      #users = User.arel_table
      @admin = AdminUser.find_by subdomain: request.subdomain

      @filter_by = ''
=begin      
      if current_user.is_girl
        if current_user.opposite_gender == 1
          users = User.active.joins(:skill).includes(:user_detail, :skill).where(:is_girl => false, :gender => current_user.opposite_gender)
          @total_users_count = users.count
          users = users.where(:skills => { :id => current_user.girl_match_skill(true) })
        else
          users = User.active.includes(:user_detail, :skill).where(:is_girl => false, :gender => current_user.opposite_gender)
          @total_users_count = users.count
        end
      else
        @total_users = users = User.active.includes(:user_detail, :skill).where(:gender => current_user.opposite_gender)
        if filter_values.present? && filter_values["programmer"]
          @filter_by = @filter_by + "#{t('programmer')}; "
          users = users.where("skill_id > ?", 0)
        else
          users = users.where("girl_match_skill_id IN (?)", current_user.programmer_match_skill_ids)
        end
      end
=end

      users = @admin.users.active.includes(:user_detail, :votables).where(:gender => current_user.opposite_gender)
      @total_users_count = users.count

      # filter if needed
      
      if filter_values.present? && (filter_values['programmer'] || filter_values["is_age"] || filter_values["avatar"] || filter_values["is_country"] || filter_values["is_city"])
        if filter_values["programmer"]
          users = users.where(:is_girl => false)
          @filter_by = @filter_by + "#{t('programmer')}; "
        end
        if filter_values["is_age"]
          age_arr = filter_values["age"].split(",")
          users = users.where(age: age_arr[0]..age_arr[1])
          @filter_by = "#{t('from')} #{age_arr[0]} #{t('to')} #{age_arr[1]}; "
        end
        if filter_values["avatar"]
          @filter_by = @filter_by + "#{t('photo')}; "
          users = users.where("avatar_file_name IS NOT NULL")
        end
        if filter_values["country"] && filter_values["is_country"]
          @filter_by = @filter_by + "#{filter_values['country']}; "
          users = users.where("country = ?", filter_values["country"])
        end
        if filter_values["city"] && filter_values["is_city"]
          @filter_by = @filter_by + "#{filter_values['city']};"
          like_verb = 'ILIKE'
          if Rails.env.production?
            users = users.where("city ILIKE ? OR city ILIKE ?", "%#{filter_values["city"].to_cyr}%", "%#{filter_values["city"].to_lat  }%")
          else
            users = users.where("city LIKE ? OR city LIKE ?", "%#{filter_values["city"].to_cyr}%", "%#{filter_values["city"].to_lat  }%")
          end

        end
      end
      # order to have VIP users and from the same country first

=begin
      if Rails.env.production?
        @users = users.order("votes.votable_id asc, CASE WHEN users.country = '#{current_user.country}' and users.referral_count >= #{vip_status} THEN 1 WHEN users.country = '#{current_user.country}' THEN 2 ELSE 3 END ASC, users.avatar_updated_at desc NULLS LAST")
                      .paginate(:per_page => 12, :page => page)
      else
        @users = users.order("votes.votable_id asc, CASE WHEN users.country = '#{current_user.country}' and users.referral_count >= #{vip_status} THEN 1 WHEN users.country = '#{current_user.country}' THEN 2 ELSE 3 END ASC, users.avatar_updated_at desc")
                      .paginate(:per_page => 12, :page => page)
      end
=end

      if Rails.env.production?
        @users = users.order("CASE WHEN avatar_file_name IS NOT NULL and users.country = '#{current_user.country}' THEN 1 WHEN avatar_file_name IS NOT NULL THEN 2 ELSE 3 END ASC, users.avatar_updated_at desc NULLS LAST")
                      .paginate(:per_page => 12, :page => page)
      else
        @users = users.order("CASE WHEN avatar_file_name IS NOT NULL and users.country = '#{current_user.country}' THEN 1 WHEN avatar_file_name IS NOT NULL THEN 2 ELSE 3 END ASC, users.avatar_updated_at desc")
                      .paginate(:per_page => 12, :page => page)
      end

      @users_hash = {}
      @users.each do |user|
        @users_hash[user.id] = user
      end

      #set users as per matching ratio (descending order)
=begin      
      @users_hash = {}
      temp_hash = {}

      @ratio_hash = {}
      unless @users.nil?
        @users.each_with_index do |user, k|
          @users_hash[user.id] = user
          temp_hash[user.id] = user
          @ratio_hash[user.id] = current_user.is_girl ? matching_ratio_user(user, current_user, true) : matching_ratio_user(current_user, user, false)
        end
      end
      @ratio_hash = Hash[@ratio_hash.sort_by{|k, v| v}.reverse]

      @ratio_hash.each do |k, v|
        @users_hash[k] = temp_hash[k]
      end
=end

    #logger.info "users hash: #{@users_hash.inspect}"
    #logger.info "users: #{@users.inspect}"
  end

  #filter user
  def filter_users
    google_analytics("dashboard", "filter-save")
    #battery_charge_discharge(current_user, "apply_filter")
    @message = Message.new
    filter_hash = ""
    if params[:filter_reset].present? && params[:filter_reset] == "1"
      filter_hash = "" #{:is_age => false, :age => params[:age], :avatar => false, :is_city => false, :city => params[:city],
                    #          :is_country => false, :country => params[:user][:country], :programmer => false}.to_json
    else
      filter_hash = {:is_age => (params[:is_age] ?  true : false), :age => params[:age], :avatar => (params[:avatar] ?  true : false), :is_city => (params[:is_city] ?  true : false), :city => params[:city],
                              :is_country => (params[:is_country] ?  true : false), :country => params[:user][:country], :programmer => (params[:programmer] ?  true : false)}.to_json
    end
    current_user.filter = filter_hash
    current_user.save
    fetch_users 1
  end

  #new search
  def create
      google_analytics("dashboard", "new")
      current_user.traits = params[:trait_radio].to_json
      current_user.girl_match_skill_id = current_user.girl_match_skill
      current_user.save
      redirect_to girls_path
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


  # show standalong page for the user
  def profile_show
    #tips
    @tips = @language.tips.includes(:language).where(:for_girl => false).map(&:content) if current_user.gender == 1
    @user = User.find_by_id(params[:id])
    if !@user.present?
      logger.error "user do not exist, redirect to index"
      redirect_to girls_path
    elsif @user.freeze_account
      logger.error "user " + @user.id.to_s + " account frozen, redirect to index"
      redirect_to girls_path
    end
  end

  #profile edit
  def profile
    @profile = "active"
    @user_detail = current_user.user_detail ? current_user.user_detail : UserDetail.new
    @allowed_profiles = current_user.allowed_from
  end

  def profile_technologies
  end

  def save_profile_notification
    notification = params[:user][:notification].present? ? true : false
    current_user.update_attributes(:notification => notification)
    @notice = t("save_successfully")
    respond_to do |format|
      format.html { render :nothing => true, :layout => ! request.xhr? }
      format.js {}
    end
  end

  #save public profile
  def save_profile
    if remotipart_submitted? && params[:user][:avatar].present?
      if current_user.update_attributes(user_params)
        google_analytics("profile-public", "photo-upload")
        @photo_notice = t("photo_uploaded_successfully")
      end
      return
    end

    if params[:user].present?
      if !params[:user][:username].present? or !params[:user][:gender].present? or !params[:user][:looking_for].present? or !params[:user][:age].present?
        @error = t("error_to_save_profile")
        respond_to do |format|
          format.html { render :nothing => true, :layout => ! request.xhr? }
          format.js {}
        end
      elsif current_user.update_attributes(user_params)
        flash[:notice] = t("profile_saved")
        mixpanel_tracker("Profile Saved", current_user)
        #@notice = t("profile_saved")
        respond_to do |format|
          format.js { render ajax_redirect_to(girls_path) }
        end
      end
    else
      respond_to do |format|
        format.js { render ajax_redirect_to(girls_path) }
      end
    end

    #if params[:user][:avatar].present?
      #increase battery
      #battery_charge_discharge(current_user, "upload_avatar")
    #end
  end

  #save private profile
  def save_profile_detail

    user_detail = current_user.user_detail

    unless user_detail
      user_detail = UserDetail.create(:user_id => current_user.id)
    end

    if remotipart_submitted? && params[:user_detail][:avatar1].present?
      if user_detail.update_attributes(user_detail_params)
        @photo_notice1 = t("photo_uploaded_successfully")
      end
      return
    end

    if remotipart_submitted? && params[:user_detail][:avatar2].present?
      if user_detail.update_attributes(user_detail_params)
        @photo_notice2 = t("photo_uploaded_successfully")
      end
      return
    end

    if params[:user_detail].present? && (params[:user_detail][:avatar1].present? || params[:user_detail][:avatar2].present?)
      google_analytics("profile-private", "photo-upload")
      #increase battery
      #battery_charge_discharge(current_user, "upload_avatar")
    end

    unless user_detail.update_attributes(user_detail_params)
      @error = t("error_to_save_profile")
      respond_to do |format|
        format.html { render :nothing => true, :layout => ! request.xhr? }
        format.js {}
      end
    else
      google_analytics("profile-private", "edit")
      #@notice = t("profiloe_saved")
      flash[:notice] = t("profile_saved")
      respond_to do |format|
        format.js { render ajax_redirect_to(girls_path) }
      end
    end
  end

  def advertise_show
    if session[:advert] == "close"
      @advertise = nil
    else
      #advertises = @language.advertises.includes(:skill, :language).where(:is_active => true)
      advertises = Advertise.where("language_id IS NULL OR language_id = ?", @language.id).includes(:skill, :language).where(:is_active => true)
      if current_user.is_girl
        advertises = advertises.where("programmer_only = ? and (gender = ? or gender = ?)", false, current_user.gender, 3)
      else
        advertises = advertises.where("gender = ? or gender = ?", current_user.gender, 3)
      end
      advertises = advertises.where("start_time < ? and expiration_time > ?", Time.now.utc, Time.now.utc)

      if current_user.country
        advertises = advertises.where("country IS NULL OR country = '' OR country = ?", current_user.country)
      end

      skill_advertises = nil
      if current_user.skill_id
        skill_advertises = advertises.where("skill_id = ? or skill_id = ?", current_user.skill_id, 0)
      end

      if skill_advertises.present?
        @advertise = skill_advertises.first
      elsif advertises.present?
        @advertise = advertises.first
        @advertise = nil if @advertise.skill_id.present? && @advertise.skill_id != 0
      else
        @advertise = nil
      end
      @advertise.update_attributes(:views => (@advertise.views + 1)) if @advertise.present?
    end
  end

  def close_advert
    session[:advert] ="close"
    render text: "advert closed for user."
  end

  def advert
    advertise = Advertise.find_by_id(params[:advert_id])
    advertise.update_attributes(:clicks => (advertise.clicks + 1)) if advertise.present?
    redirect_to params[:url] ? params[:url] : girls_path
  end

  def discharge_battery
    #battery_charge_discharge(current_user, "view_profile")
    if !current_user.hidden? && params[:user_id].present?
      user = User.find(params[:user_id])
      if user.present?
        #increase counter for profile view to send email
        user.update_attributes(:profile_views => (user.profile_views + 1))
        # log that user's profile was viewed
        google_analytics("profile-public", "viewed", user)
        # log that current user viewed some other user's profile
        google_analytics("profile-public", "view", current_user)

        profile_view = ProfileView.find_by(:from => current_user.id, :to => user.id)
        if profile_view
          profile_view.update_attributes(:last_view => Time.now.utc, :view_count => (profile_view.view_count + 1), :is_read => false)
        else
          user.view_from.create(:from => current_user.id, :last_view => Time.now.utc, :view_count => 1)
        end

      end
    end
    render text: "battery discharged"
  end

  def increase_battery_size
    if params[:action_type] == "social_invite"
      user_battery_size = current_user.battery_size + 50
      user_points = current_user.points
      user_battery_size = user_battery_size > user_points ? user_points : user_battery_size
      current_user.update_attributes(:battery_size => user_battery_size)
    end
    render text: "invited button clicked."
  end

  def notify_profile
    current_user.update_attributes(:notification_profile => (current_user.notification_profile ? false : true))
    render text: "profile notification changed"
  end

  def skip_traits
    traits_hash = {"0" => "Young","1" => "Generious","2" => "Attentive","3" => "Kind","4" => "Responsible","5" => "Gifted","6" => "Funny","7" => "Romantic","8" => "Resourceful","9" => "Practical","10" => "Love kids","11" => "Wealthy","12" => "Canny","13" => "Family-man","14" => "With bad habits","15" => "Modest","16" => "Conservative about sex" }
    skill_ids = Skill.all.map(&:id)
    skill_id = skill_ids.sample
    current_user.update_attributes(:traits => traits_hash.to_json, :girl_match_skill_id => skill_id)
    redirect_to girls_path
  end

  private
    def user_params
      params.require(:user).permit!
    end

    def user_detail_params
      params.require(:user_detail).permit!
    end

end
