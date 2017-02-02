class JobsController < ApplicationController

  layout "girl"

  #before_action :authenticate_user!, :except => [:show, :index]
  
  # fetch latest chat messages  
  before_action do 
    fetch_messages 1
  end  
  
  def index
    @jobs_active = "active"
    @admin = AdminUser.find_by subdomain: request.subdomain
    fetch_jobs
  end

  def next_jobs
    fetch_jobs
  end

  def fetch_jobs
    # fetch only APPROVED jobs
    @all_jobs = Job.approved.where(:user_id => @admin.users.map(&:id)).paginate(:per_page => 12, :page => params[:page])
  end
 
  def show    
    @job = Job.find_by_id(params[:id])
  end  

  private
  
  def job_params
    params.require(:job).permit!
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
