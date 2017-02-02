ActiveAdmin.register User do
permit_params :username, :email, :about_me, :country, :city, :skill_id, :traits, :avatar, :is_girl, :report_abuse, :referral_count, :freeze_account, :is_active, :password, :password_confirmation, :is_instructor

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


  controller do
    
    def scoped_collection
      if current_admin_user.has_role?(:superadmin)
        User.all
      else
        User.joins(:adminuser_users).where('adminuser_users.admin_user_id = ?',current_admin_user.id)
      end
    end    
    
    def update
      if params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      if params[:user][:email].blank?
        params[:user].delete("email")
        params[:user].delete("email_confirmation")
      end
      super
    end

    def create
      @user = User.new(params[:user].permit!)
      if current_admin_user.has_role?(:superadmin)
        @user.save!
      else
        @user.adminuser_users.build(:admin_user_id => current_admin_user.id)
      end
      super
    end
  end

  before_save do |user|
    user.skip_confirmation!
    user.skip_reconfirmation!
  end  
  
  batch_action :send_invitation do |selection|
    User.find(selection).each do |resource|
       resource.invitation = true
       resource.save
       opts = { :resource => resource, :token => SecureRandom.hex(10), :password => resource.email.split("@")[0] }
       Mailer.send_invitation(resource.email, opts).deliver
               
       #InvitationWorker.perform_async(resource.id)
    end
    redirect_to collection_path, :alert => "Sent invitations to selected users."
  end  

  member_action :send_invitation, :method=>:get do
       resource = User.find(params[:id])
       resource.invitation = true
       resource.save
       @id = resource.id
       opts = { :resource => resource, :token => SecureRandom.hex(10), :password => resource.email.split("@")[0] }
       Mailer.send_invitation(resource.email, opts).deliver       
       #InvitationWorker.perform_async(resource.id)
   end

  index do
    selectable_column
    column :username
    column :email
    column :country
    column :skill_id
    column :is_girl
    column :referral_count
    column :referred_user
    column :is_active
    column :created_at, :sortable => :created_at do |obj|
      obj.created_at.localtime.strftime("%B %d, %Y %H:%M")
    end
    
    column :last_sign_in_at, :sortable => :last_sign_in_at do |obj|
      obj.last_sign_in_at.localtime.strftime("%B %d, %Y %H:%M") if obj.last_sign_in_at.present?
    end    
    
    column :invitation do |u|
      if u.invitation
        raw 'Sent'
      else  
        raw "<div id='send_"+u.id.to_s+"'>" + (link_to 'Send', send_invitation_path(u.id, locale: session[:lang]), :class => 'view_description button', :remote => true) + "</div>"
      end
    end
    actions
  end
  
  filter :username
  filter :email
  filter :country
  filter :city
  filter :created_at
  filter :last_sign_in_at
  filter :skill_id
  filter :is_girl
  filter :is_active  

  form do |f|
    f.inputs do
      f.input :username
      f.input :email
      f.input :password, as: :password
      f.input :password_confirmation, as: :password
      f.input :about_me, as: :ckeditor
      #f.input :country, as: :select, collection: country_select("user", "country", locale: "en")
      f.input :country
      f.input :city
      f.input :skill_id, as: :select, collection: Skill.all.map{ |skill| [skill.name, skill.id] }
      f.input :traits, as: :ckeditor
      f.input :avatar, as: :file
      f.input :is_girl, as: :radio
      f.input :referral_count
      f.input :is_active, as: :radio
      f.input :freeze_account, as: :radio
      f.input :is_instructor, as: :radio
    end
    f.actions
  end

end
