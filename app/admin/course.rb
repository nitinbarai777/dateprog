ActiveAdmin.register Course do
permit_params :instructor_id, :language_id, :title, :description, :avatar, :is_published, :is_approved, :technology_list, :congratulations

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

  collection_action :autocomplete_tag_name, :method => :get

  controller do
    autocomplete :tag, :name, :full => true, :display_value => :funky_method

    def scoped_collection
      if current_admin_user.has_role?(:superadmin)
        Course.all
      else
        Course.where(:instructor_id => current_admin_user.users.map(&:id))
      end    
    end
  end

  index do
    selectable_column
    column :instructor
    column :language
    column :title
    column :is_published
    column :is_approved
    column :created_at, :sortable => :created_at do |obj|
      obj.created_at.localtime.strftime("%B %d, %Y %H:%M")
    end
    actions
  end
  
  filter :instructor
  filter :language
  filter :title
  filter :is_published
  filter :is_approved
  filter :created_at 

  form do |f|
    f.inputs do
      if current_admin_user.has_role?(:superadmin)
        f.input :instructor, as: :select, :collection => User.all, include_blank: false
      else
        f.input :instructor, as: :select, :collection => current_admin_user.users, include_blank: false
      end
        f.input :language_id, as: :select, collection: Language.all.map{ |language| [language.name, language.id] }, include_blank: false
        f.input :title
        f.input :description, as: :ckeditor
        f.input :is_published, as: :radio
        f.input :is_approved, as: :radio
        f.input :avatar, as: :file, :hint => image_tag(f.object.avatar.url)
        f.input :technology_list, :as => :autocomplete, :url => autocomplete_tag_name_admin_courses_path, input_html: { :multiple => true, 'data-delimiter' => ',', :name => "course[technology_list]"}
        f.input :congratulations, as: :ckeditor
    end
    f.actions
  end

end
