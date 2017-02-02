ActiveAdmin.register SkillTrait do
  
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :skill_id, :trait_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end
  
  index do
    column :skill
    column :trait
    actions
  end  

  form do |f|
    f.inputs do
      f.input :skill_id, as: :select, collection: Skill.all.map{ |skill| [skill.name, skill.id] }
      f.input :trait_id, as: :select, collection: Trait.all.map{ |trait| [trait.name, trait.id] }
      #f.input :trait_id, as: :select, collection: Trait.all.map{ |trait| [trait.name, trait.id] }, :multiple => true, :include_blank => false, :selected => (skill_trait.trait.id if !skill_trait.trait.nil?)
    end
    f.actions
  end

end
