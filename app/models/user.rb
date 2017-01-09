class User < ActiveRecord::Base
  
  include ApplicationHelper
  
  require "countries"

  acts_as_voter

  acts_as_votable
  
  before_create :set_locale
  before_create :set_notification_token

  MALE = 1
  FEMALE = 2

  acts_as_taggable
  
  acts_as_taggable_on :technologies  

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :database_authenticatable, :registerable, :recoverable, 
  :rememberable, :trackable, :validatable, :omniauthable , :confirmable

  has_many :authentications, class_name: 'UserAuthentication', dependent: :destroy
   
  belongs_to :skill

  belongs_to :girl_skill, class_name: "Skill", foreign_key: :girl_match_skill_id

  belongs_to :referred_user, class_name: "User", foreign_key: :referred_user_id
  
  has_many :messages
  
  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id, dependent: :destroy
  has_many :received_messages, class_name: "Message", foreign_key: :recipient_id, dependent: :destroy
  
  has_one :user_detail, dependent: :destroy
  
  has_many :allowed_from, class_name: "ProfileAccess", foreign_key: :to, dependent: :destroy
  has_many :allowed_to, class_name: "ProfileAccess", foreign_key: :from, dependent: :destroy
  
  has_many :view_from, class_name: "ProfileView", foreign_key: :to, dependent: :destroy
  has_many :view_to, class_name: "ProfileView", foreign_key: :from, dependent: :destroy

  has_many :invites, dependent: :destroy
  
  has_many :user_authentications, dependent: :destroy

  has_many :instructor_courses, class_name: "Course", foreign_key: :instructor_id, dependent: :nullify 

  has_many :user_courses

  has_many :courses, through: :user_courses, source: :course

  has_many :jobs

  has_many :votables, -> { where vote_flag: true }, class_name: "Vote", foreign_key: :voter_id, dependent: :destroy

  has_many :voters, class_name: "Vote", foreign_key: :votable_id, dependent: :destroy
  
  scope :locale, ->(locale_id) { where(:language => locale_id)}
  
  scope :active, -> {where(:is_active => true, :freeze_account => false)}

  has_attached_file :avatar, 
    :styles => { :medium => ["256x256#"], :thumb => ["100x100>"], :small => ["48x48>"]   },
    :convert_options => { :all => '-auto-orient' },
    :default_url => "/noimage.gif",
    :s3_protocol => :https

  validates_attachment :avatar, :presence => true, :content_type => { :content_type => ["image/jpeg", "image/png", "image/gif"] }, :size => { :in => 0..2500.kilobytes }, :if => :avatar_attached?

  def set_locale
    self.locale = I18n.locale
  end

  #this method is called by devise to check for "active" state of the model
  def active_for_authentication?
    #remember to call the super
    #then put our own check to determine "active" state using 
    #our own "is_active" column
    super && self.is_active?
  end  
  
  def self.create_from_omniauth(params, provider)
    if provider.name == 'twitter' 
      if params['info']['nickname'].present?
        email = params['info']['nickname'].gsub(" ", "")
        email = email+'@demo.herokuapp.com'
      else
        email = ''
      end
      username = params['info']['nickname']
    else
      email = params['info']['email']
      username = params['info']['name']
    end

    attributes = {
      username: username,
      email: email,
      password: Devise.friendly_token
    }

    u = create(attributes)
  end

  def is_private_profile_filled?
    pfl = user_detail
    if pfl.present?
      if !pfl.from.present? || !pfl.fav_movie.present? || !pfl.last_movie.present? || !pfl.fav_singer.present? || !pfl.make_laugh.present? || !pfl.make_cry.present? || !pfl.like_animals.present? || !pfl.my_dream.present? || !pfl.like_live.present?
        return false
      else
        return true
      end
    else
      return false
    end
  end

  def is_activated?
    is_active && !freeze_account
  end

  def is_abused? current_user_id
    ReportAbuse.find_by_from_and_to(self.id, current_user_id)
  end

  def is_allow? user_id
    self.allowed_from.where(:from => user_id, :allow => true).first
  end
  
  def request_accepted? user_id
    self.allowed_to.where(:to => user_id, :allow => true).first
  end
  
  def is_requested? user_id
    self.allowed_to.where(:to => user_id).first
  end    

  def opposite_gender
    if self.looking_for.present? && (self.looking_for == MALE || self.looking_for == FEMALE)
      self.looking_for == MALE ? MALE : FEMALE
    else
      self.gender == MALE ? FEMALE : MALE
    end    
  end

  def set_notification_token
    unless self.notification_token.present?
      self.notification_token = "#{self.id}#{SecureRandom.hex(10)}"
    end  
  end

  def avatar_attached?
    self.avatar.file?
  end
  
  def user_avatar current_user
    #avatar.exists? ? avatar(:medium) : (current_user.gender == FEMALE ? "girl-default.png" : "boy-default.jpeg")
    avatar.exists? ? avatar(:medium) : (gender == FEMALE ? girl_icon : boy_icon)
  end

  def random_image
    gender == FEMALE ? girl_icon : boy_icon
  end

  def user_age
    if age.nil? || age < 18
      18
    else 
      self.age
    end
  end

  def boy_icon
    ["boy1.png", "boy2.png", "boy3.png", "boy4.png", "boy5.png", "boy6.png", "boy7.png", "boy8.png", "boy9.png", "boy10.png", "boy11.png",
      "boy12.png", "boy13.png", "boy14.png", "boy15.jpg", "boy16.png", "boy17.png"].sample
  end

  def girl_icon
    ["girl1.png", "girl2.png", "girl3.png", "girl4.png", "girl5.png", "girl6.png", "girl7.png", "girl8.png", "girl9.png", "girl10.png", "girl11.png",
      "girl12.png", "girl13.png", "girl14.png", "girl15.png", "girl16.png", "girl17.png"].sample
  end  

  def user_avatar_thumb
    avatar.exists? ? avatar(:thumb) : (gender == MALE ? "boy.jpeg" : "girl.jpeg")
  end

  # warning: no small images yet!
  def user_avatar_small
    avatar.exists? ? avatar(:small) : (gender == MALE ? "boy.jpeg" : "girl.jpeg")
  end
  
  def user_avatar_medium
    avatar.exists? ? avatar(:medium) : "noimage.gif"
  end      
  
  def girl_match_skill second_skill=false
      skill_hash = {}
      Skill.all.each do |skill|
        skill_hash[skill.name] = skill.skill_traits.includes(:skill, :trait).collect { |skill_trait| skill_trait.trait.name } 
      end
      result_hash = {}
      
      traits = Trait.count
      current_user_traits = self.traits.present? ? ActiveSupport::JSON.decode(self.traits) : ""
      
      #get programmers based on set skills           
      skill_hash.each do |k, v|
        for n in 0..traits-1
          if v.include? current_user_traits["#{n}"]
            if result_hash[k]
              result_hash[k] = result_hash[k] + 1
            else
              result_hash[k] = 1
            end
          end
        end
      end
      
      result = result_hash.sort_by {|k,v| v}.reverse
      if second_skill
        skill_names = []

        skill = Skill.find(self.girl_match_skill_id)
        unless skill.present?
          skill = Skill.first
        end

        case (Time.now.utc.to_date.day+skill.index)%14
        when 0
          rand_arr = [1,2,3,4,5,6,7,8]
        when 1
          rand_arr = [7,8,9,10,11,12,13]
        when 2
          rand_arr = [4,5,6,7,8,9,10,11]
        when 3
          rand_arr = [1,2,3,4,5,6,7,8]
        when 4
          rand_arr = [7,8,9,10,11,12,13]
        when 5
          rand_arr = [4,5,6,7,8,9,10,11]
        when 6
          rand_arr = [1,2,3,4,5,6,7,8]
        when 7
          rand_arr = [7,8,9,10,11,12,13]
        when 8
          rand_arr = [4,5,6,7,8,9,10,11]
        when 9
          rand_arr = [1,2,3,4,5,6,7,8]
        when 10
          rand_arr = [7,8,9,10,11,12,13]
        when 11
          rand_arr = [4,5,6,7,8,9,10,11]
        when 12
          rand_arr = [1,2,3,4,5,6,7,8]
        when 13
          rand_arr = [7,8,9,10,11,12,13]
        end
        rand_arr.each do |i|
          skill_names << result[i][0] if result[i].present?
        end
        
        skill_ids = Skill.where(:name => skill_names).map(&:id)
      else  
        result[0] ? Skill.find_by_name(result[0][0]).id : ""
      end  
  end
  
  def programmer_match_skill_ids
    skill_ids_hash = {}

    Skill.all.each_with_index do |skill, index|
      skill_ids_hash[index] = skill.id
    end

    skill = Skill.find(self.skill_id)
    unless skill.present?
      skill = Skill.first
    end

    case (Time.now.utc.to_date.day+skill.index)%14
    when 0
      rand_arr = [1,2,3,4,5,6,7,8]
    when 1
      rand_arr = [7,8,9,10,11,12,13]
    when 2
      rand_arr = [4,5,6,7,8,9,10,11]
    when 3
      rand_arr = [1,2,3,4,5,6,7,8]
    when 4
      rand_arr = [7,8,9,10,11,12,13]
    when 5
      rand_arr = [4,5,6,7,8,9,10,11]
    when 6
      rand_arr = [1,2,3,4,5,6,7,8]
    when 7
      rand_arr = [7,8,9,10,11,12,13]
    when 8
      rand_arr = [4,5,6,7,8,9,10,11]
    when 9
      rand_arr = [1,2,3,4,5,6,7,8]
    when 10
      rand_arr = [7,8,9,10,11,12,13]
    when 11
      rand_arr = [4,5,6,7,8,9,10,11]
    when 12
      rand_arr = [1,2,3,4,5,6,7,8]
    when 13
      rand_arr = [7,8,9,10,11,12,13]
    end

    skill_result_ids = []
    rand_arr.each do |i|
      skill_result_ids << skill_ids_hash[i] if skill_ids_hash[i].present?
    end
    skill_result_ids

=begin    
      skill_ids = Skill.all.map(&:id)
      idx = skill_ids.index(self.skill_id)
      if idx
        [skill_ids[idx-1], skill_ids[(idx+1)%skill_ids.size], self.skill_id]
      else
        [self.skill_id]
      end
=end      
  end
  
  def received_sent_messages
    Message.where("recipient_id = ? or sender_id = ?", self.id, self.id)
  end
  
  def received_or_sent_messages_user u_id
    Message.where("(recipient_id = ? and sender_id = ? and system_message = ?) or (recipient_id = ? and sender_id = ?)", u_id, self.id, false, self.id, u_id)
  end  
  
  def name
    uname = username.present? ? username : email.split(/[.\+\@1-9\(\)]/)[0]
    uname.to_s.scan(/\S.{0,#{15}}\S(?=\s|$)|\S+/)[0]
  end

  def name_with_unread_message(current_user)
    unread_messages_count = Message.where("recipient_id = ? and sender_id = ? and is_read = ?", current_user.id, self.id, false).count
    if unread_messages_count > 0
      "#{self.name}(#{unread_messages_count})"
    else
      self.name
    end
  end
  
  def profile
    profile_data = username.present? ? username : email.split(/[.\+\@1-9\(\)]/)[0]
    profile_data = "<strong>#{profile_data}</strong>\n"
    profile_data = profile_data + "#{I18n.t('city')} #{city_lat}\n" if city.present?
    profile_data = profile_data + "#{I18n.t('country')} #{country}\n\n" if country.present?
    profile_data = profile_data + "#{wrap(about_me, 100)}" if about_me.present?
    profile_data.html_safe
  end
  
  def profile_without_about_me
    #profile_data = username.present? ? username : email.split(/[.\+\@1-9\(\)]/)[0]
    #profile_data = "#{age} #{I18n.t('years')}, "
    profile_data = ""
    profile_data = profile_data + "#{city_lat}" if city.present?
    profile_data = profile_data + (profile_data.present? ? ", #{country_name}" : "#{country_name}")
    profile_data.to_s.scan(/\S.{0,#{32}}\S(?=\s|$)|\S+/)[0]
  end  

  def city_lat
    if city.present? && I18n.locale.to_s != 'ru'
      Cyrillizer.language = :russian
      city.to_lat
    else
      city
    end
  end

  def profile_viewed_by
    profile_data = ""
    profile_data = "#{name.chars.first}****"
    #profile_data = profile_data + ", #{age}"
    #profile_data = profile_data + ", #{city}" if city.present?
    profile_data = profile_data + ", #{country_name}"
    profile_data.to_s.scan(/\S.{0,#{32}}\S(?=\s|$)|\S+/)[0]
    profile_data
  end  
  
  def country_name
    (country.present? && Country[country]) ?  Country[country].translations['en'].to_s : country 
  end
  
  def profile_completed?
    if !username.present? || !age.present? || gender == 0 || !gender.present?
      return false  
    end
    return true
  end
  
  def is_male?
    self.gender == MALE
  end  

  def is_female?
    self.gender == FEMALE
  end  
  
=begin  
  def online?
    if current_sign_in_at.present? 
      if last_sign_out_at.present? 
        ((current_sign_in_at > last_sign_out_at) && ((Time.now.to_date-current_sign_in_at.to_date).to_i == 0)) ? true : false
      else 
        ((Time.now.to_date-current_sign_in_at.to_date).to_i == 0) ? true : false     
      end
    else
      false
    end
  end
=end
  def online?
    current_sign_in_at.present? ? (current_sign_in_at > 10.minutes.ago) : false
  end

  def filter_on?
    if filter.present?
      filter_values = ActiveSupport::JSON.decode(filter)
      if filter_values.present? && (filter_values["is_age"] || filter_values["avatar"] || filter_values["is_country"] || filter_values["is_city"] || filter_values["programmer"])
        true
      else
        false
      end
    else
      false
    end
  end


  def was_recently_active?
    # (referral_count >= vip_status) ||
    # vip users are who confirmed 5 days or less ago
    current_sign_in_at.present? ? current_sign_in_at > 15.days.ago : false
    # true
  end

  def completed_courses_count
    self.user_courses.where(:is_completed => true).count
  end
  
  def instructor_courses_approved_count
    self.instructor_courses.where(:is_approved => true).count
  end

  def is_vip_status?
    true
    # completed_courses_count >= vip_status || instructor_courses_approved_count>0
  end

  def profile_notifications
    view_from.order("id desc")
  end

  def unread_profile_notifications
    view_from.where(:is_read => false)
  end

  def last_seen_days
    if current_sign_in_at.present?
      (((Time.now.utc - current_sign_in_at).to_i.abs)/(60*60*24)).to_i
    else
      (((Time.now.utc - updated_at).to_i.abs)/(60*60*24)).to_i
    end
  end
  
  def battery_capacity_remain_duration
    remain_duration = (battery_size/points)*100
    remain_duration.round if remain_duration > 0
  end
           
  def battery_increase_percentage(action_capacity)
    ((action_capacity/points)*100).round
  end

  # returns messages for the course info based on user info on prevously passed courses
  # is_current_user: true if we render for current user, false if for external user
  def get_course_info course_id
    user_course = user_courses.find_by_course_id(course_id)
    is_completed = false # is completed indicator
    total_levels = 0 # total courses
    completed_levels = 0 # means no levels are passed at all by default
    if user_course.present?
      # save total number of courses
      total_levels = user_course.course.course_levels.count
      if user_course.is_completed
        is_completed = true
      else 
        # get number of passed levels
        completed_levels = user_course.passed_levels
      end
    end
    # return array with course info
    return [is_completed, total_levels, completed_levels]
  end
     
=begin        
        if is_current_user
          msg = I18n.t('you_already_completed_course')
        else
          msg = I18n.t('has_completed_course')
        end
        c_completed = true
      else
        total_levels = user_course.course.course_levels.count
        passed_levels = user_course.passed_levels
        if is_current_user
          msg = I18n.t('you_have_completed_levels', total_levels: total_levels, passed_levels: passed_levels)
        else
          msg = I18n.t('has_completed_levels', total_levels: total_levels, passed_levels: passed_levels)
        end
        c_completed = false
      end
      u_course = true
    else
      u_course = false
      c_completed = false
      msg = ''
    end
    [u_course, c_completed, msg]
  end
=end
  
  def moderator?
    # currently just check the id of the user
    self.id<5
  end
  
  def hidden?
    # all profiles with id<7 are considered as hidden
    # and not displayed along with other users
    self.id<7
  end
           
end
