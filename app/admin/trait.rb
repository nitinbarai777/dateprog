ActiveAdmin.register Trait do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :name, :index
  
  index do
    column :name
    column :index
    actions
  end    
  
  form do |f|
    f.inputs do
      f.input :name
      f.input :index
    end
    f.actions
  end   
    
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


end
