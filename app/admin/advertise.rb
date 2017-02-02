ActiveAdmin.register Advertise do
  permit_params :body, :language_id, :start_time, :expiration_time, :programmer_only, :skill_id, :is_active, :gender, :country, :views, :clicks, :close_text

  menu :if => proc { current_admin_user.has_role?(:admin)}
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

  index do
    column :language
    column :country
    column :start_time, :sortable => :start_time do |obj|
      obj.start_time.localtime.strftime("%B %d, %Y %H:%M")
    end
    column :expiration_time, :sortable => :expiration_time do |obj|
      obj.expiration_time.localtime.strftime("%B %d, %Y %H:%M")
    end
    column :programmer_only
    column :skill
    column :views
    column :clicks
    column :conversion_rate do |c|
      ((c.clicks*c.views)/100).to_s + "%"
    end    
    column :is_active
    
    actions
  end    


  form do |f|
    f.inputs do
      f.input :body, as: :ckeditor
      f.input :language_id, as: :select, collection: [['All', '']] + Language.all.map{ |language| [language.name, language.id] }, include_blank: false
      f.input :country, as: :select, collection: [['All', '']] + User.where("country IS NOT NULL AND country != ''").pluck(:country).uniq.sort, include_blank: false
      f.input :start_time
      f.input :expiration_time
      f.input :programmer_only, as: :radio
      f.input :skill_id, as: :select, collection: [['No Skill', '0']] + Skill.all.map{ |skill| [skill.name, skill.id] }
      f.input :gender, as: :select, collection: [['Both', '3']] + [['Male', '1']] + [['Female', '2']] 
      f.input :close_text
      f.input :is_active, as: :radio
      
    end
    f.actions
  end


end
