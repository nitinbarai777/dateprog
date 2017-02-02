ActiveAdmin.register ProfileView do
permit_params :from, :to, :last_view, :view_count, :is_read


  controller do
    def scoped_collection
      if current_admin_user.has_role?(:superadmin)
        ProfileView.all
      else
        ProfileView.where('`from` in (?) or `to` in (?)',current_admin_user.users.map(&:id),current_admin_user.users.map(&:id))
      end
    end
  end

  index do
    selectable_column
    column :from
    column :to
    column :last_view, :sortable => :last_view do |obj|
      obj.last_view.localtime.strftime("%B %d, %Y %H:%M")
    end    
    column :view_count
    column :is_read
    actions
  end
  
  filter :from
  filter :to
  filter :last_view
  filter :view_count
  filter :is_read

  form do |f|
    f.inputs do
       if current_admin_user.has_role?(:superadmin)
        f.input :from, as: :select, collection: User.all, include_blank: false
        f.input :to, as: :select, collection: User.all, include_blank: false
       else
        f.input :from, as: :select, collection: current_admin_user.users.map{ |user| [user.name, user.id] }, include_blank: false
        f.input :to, as: :select, collection: current_admin_user.users.map{ |user| [user.name, user.id] }, include_blank: false
       end        
        f.input :last_view
        f.input :view_count
        f.input :is_read, as: :radio

    end
    f.actions
  end

end
