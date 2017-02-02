ActiveAdmin.register UserCourse do
permit_params :user_id, :course_id, :passed_levels, :is_completed

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
  includes :course

  controller  do
    def scoped_collection
      if current_admin_user.has_role?(:superadmin)
        UserCourse.all
      else
        UserCourse.where(:user_id => current_admin_user.users.map(&:id))
      end
    end
  end

  index do
    selectable_column
    column :user_id
    column :course_id
    column :passed_levels
    column :is_completed
    column :created_at, :sortable => :created_at do |obj|
      obj.created_at.localtime.strftime("%B %d, %Y %H:%M")
    end
    actions
  end
  
  filter :user_id
  filter :course_id
  filter :is_completed 
  filter :created_at 

  form do |f|
    f.inputs do
      if current_admin_user.has_role?(:superadmin)
        f.input :user, as: :select, :collection => User.all, include_blank: false
        f.input :course, as: :select, :collection => Course.all, include_blank: false
      else
        f.input :user, as: :select, :collection => current_admin_user.users, include_blank: false
        f.input :course, as: :select, :collection => Course.where(:instructor_id => current_admin_user.users.each{ |user| user.instructor_courses.each {|u| u.id} }), include_blank: false
      end
      # f.input :course, as: :select, :collection => Course.where(:id => current_admin_user.users.collect{ |user| user.instructor_courses.map(&:id) } )
      # f.input :course_id, as: :select, collection: Course.all.map{ |course| [course.title, course.id] }
      f.input :passed_levels
      f.input :is_completed, as: :radio
      
    end
    f.actions
  end

end
