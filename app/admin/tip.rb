ActiveAdmin.register Tip do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :content, :for_girl, :language_id
  
  index do
    column :language
    column :content
    column :for_girl
    actions
  end  
  
  form do |f|
    f.inputs do
      f.input :language_id, as: :select, collection: Language.all.map{ |language| [language.name, language.id] }
      f.input :content, as: :ckeditor
      f.input :for_girl, as: :radio
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
