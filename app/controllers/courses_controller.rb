class CoursesController < ApplicationController

  layout "girl"

  before_action :authenticate_user!, :except => [:show, :index]
  
  # fetch latest chat messages  
  before_action do 
    fetch_messages 1
  end  
  

  def index
    @admin = AdminUser.find_by subdomain: request.subdomain
    @courses_active = "active"
    if current_user.present? && params[:course_id].present?
      course = Course.find_by_id(params[:course_id])
      flash[:notice] = course.congratulations.present? ? course.congratulations.html_safe : t("course_success", title: course.title)
    end
    fetch_courses
  end

  def next_courses
    fetch_courses
  end

  def fetch_courses
    # fetch only APPROVED courses
    @all_courses = Course.approved.where(:instructor_id => @admin.users.map(&:id)).paginate(:per_page => 12, :page => params[:page])
  end

  #new course
  def create
  end
  
  def show
    session[:level_number] = session[:course] = nil
    @course = Course.find_by_id(params[:id])
  end  

  def users
    filter_users
  end

  def next_users
    filter_users params[:page]
  end

  def filter_users page=1
    @course = Course.find_by_id(params[:course_id])
    users = @course.completed_and_other_users
    if Rails.env.production?
      @users = users.order("CASE WHEN users.country = '#{current_user.country}' and users.referral_count >= #{vip_status} THEN 1 WHEN users.country = '#{current_user.country}' THEN 2 ELSE 3 END ASC, users.avatar_updated_at desc NULLS LAST")
                    .paginate(:per_page => 12, :page => page)
    else
      @users = users.order("CASE WHEN users.country = '#{current_user.country}' and users.referral_count >= #{vip_status} THEN 1 WHEN users.country = '#{current_user.country}' THEN 2 ELSE 3 END ASC, users.avatar_updated_at desc")
                    .paginate(:per_page => 12, :page => page)
    end    
    @users_hash = {}
    @users.each do |user|
      @users_hash[user.id] = user
    end   
  end
  
  private
  
  def course_params
    params.require(:course).permit!
  end
  
  # fetch chat messages
  def fetch_messages page
    if current_user
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

end
