module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    icon = sort_direction == "asc" ? "glyphicon glyphicon-chevron-up" : "glyphicon glyphicon-chevron-down"
    icon = column == sort_column ? icon : ""
    link_to "#{title} <span class='#{icon}'></span>".html_safe, params.merge(:column => column, :direction => direction, :page => nil),remote: :true    
  end

  def mobile_or_tablet_request?
    mobile_request? or tablet_request?
  end

  def vip_status
    return 10
  end
  
  def vip_status_max_contacts  
    # return 7 # disabled to change to 100 as girls are unable to chat without VIP
    return 100
  end

  def time_difference dt
    dt_int = Time.now.utc - dt
    secs  = dt_int.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      if days > 30 
        t('more_than_month_ago')
      else 
        "#{days} #{t('days')}"
      end
      #if days > 7
      #  dt.to_s(:default_date_time)
      #else
      #  "#{days} #{t('days')}"
      #end
    elsif hours > 0
      "#{hours} #{t('hrs')}"
    elsif mins > 0
      "#{mins} #{t('mins')}"
    elsif secs >= 0
      if secs == 0
        "Now"
      else
        "#{secs} #{t('secs')}"
      end
    end
  end  
  
  def matching_ratio_user programmer, girl, is_girl
    if is_girl or (!is_girl and girl.is_girl)
      girl_programmer_match programmer, girl
    else
      programmer_programmer_match programmer, girl
    end
  end  
  
  def girl_programmer_match programmer, girl
      if programmer.skill_id == girl.girl_match_skill_id
        return 100
      else
        programmer_skill_traits = programmer.skill.skill_traits.includes(:skill, :trait).collect { |skill_trait| skill_trait.trait.name }
        girl_traits = girl.traits
        if girl_traits.present?
          traits = ActiveSupport::JSON.decode(girl_traits)
          traits_count = Trait.count - 1
          result_hash = 0
          for n in 0..traits_count
            if programmer_skill_traits.include? traits["#{n}"]
              result_hash = result_hash + 1
            end
          end
          (result_hash*100)/17
        else
          0  
        end
      end
  end
  
  def programmer_programmer_match programmer, girl
    if programmer.skill_id == girl.skill_id
      100
    else
      result_hash = 1
      girl_skill = girl.skill
      
      if girl_skill.present?
        girl_skill_traits = girl_skill.skill_traits.includes(:skill, :trait).collect { |skill_trait| skill_trait.trait.name }
      else
        girl_skill_traits = girl.traits.present? ? ActiveSupport::JSON.decode(girl.traits) : []
      end  
      
      programmer_skill_traits = programmer.skill.skill_traits.includes(:skill, :trait).collect { |skill_trait| skill_trait.trait.name }
      girl_skill_traits.each do |skill|
        if programmer_skill_traits.include? skill
          result_hash = result_hash + 1
        end
      end
      (result_hash*100)/23  
    end
  end  
  
  def wrap(s, width=78)
    s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
  end  
  
end
