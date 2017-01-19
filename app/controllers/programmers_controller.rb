class ProgrammersController < ApplicationController
  
  include ApplicationHelper
  layout "girl"
  before_action :authenticate_user!
  
  
  def index
    @console = "active"
    google_analytics("console", "open")
    # get latest chat messages
    fetch_messages 1
  end
  
  ################
  # console  
  ################
  
  def console_girls
    if  current_user.profile_completed?
      if  current_user.skill
        if params[:inbox].present?
          if params[:console_msg_reply].present?
            console_msg_reply_offset = params[:console_msg_reply].to_i - 1
            console_msg_reply_offset = (console_msg_reply_offset > 1) ? console_msg_reply_offset : 1            
            messages = current_user.received_sent_messages.order("id asc").offset(console_msg_reply_offset).limit(1)
            messages_data = ''
            if messages.present?        
              if params[:msg].present?
                params[:msg] = params[:msg].gsub(/(?:f|ht)tps?:\/[^\s]+/, t("link_removed"))
                message = Message.create(recipient_id: messages.first.sender.id, sender_id: current_user.id, body: params[:msg].gsub("'", '').gsub('"', ''))
                messages_data = t("message_sent_to", recipient: messages.first.sender.name)
              end
            end  
            render :text => messages_data.present? ? messages_data : t("recipient_not_found")
          else  
            if params[:console_more].present?
              console_more_offset = params[:console_more].to_i - 1
              console_more_offset = (console_more_offset > 1) ? console_more_offset : 1
              messages = current_user.received_sent_messages.order("id asc").offset(console_more_offset).limit(1)
              unless messages.present?
                messages_data = t("notification_not_found")
              else 
                messages_data = ""
              end  
            else  
              messages = current_user.received_sent_messages.order("id asc").limit(200)
              messages_data = t("notifications_count", count: messages.count)
            end
            messages.each_with_index do |message, k|
              girl = message.sender
              if girl.present?
                if params[:console_more].present?
                  messages_data = messages_data + render_to_string(:partial => 'programmers/message', :layout => false, :locals => {:girl => girl, :message => message})
                else
                  color_class = (message.sender.present? && message.sender.id == current_user.id) ? "#3071A9" : ""
                  messages_data = messages_data + "\n<strong style='color:#{color_class};'><strong>#{k+1}.</strong> #{girl.name} (#{t('uid')}#{girl.id})</strong> - #{wrap(message.body, 100)}"
                end
              end
            end        
            render :text => messages_data
          end  
        else
            girls_data = ""
            @girls = []
            if params[:console_find].present? || params[:console_more].present?
              traits = current_user.skill.skill_traits.collect { |skill_trait| skill_trait.trait.name }
              girls = User.active.where(:gender => current_user.opposite_gender)
              if traits.present?
                search_keys = ''
                traits.each do |trait|
                  search_keys = "#{search_keys} traits LIKE '%#{trait}%' OR"
                end
                3.times do search_keys.chop! end
                search_keys.strip!
                if params[:console_more].present?
                  if params[:console_more].to_i >= 1
                    
                    #messages = current_user.received_messages.order("id desc").offset(params[:console_more].to_i-1).limit(1)
                    #@girls = girls.where(search_keys).offset(params[:console_more].to_i-1).limit(1)

                    @girls = User.where(:id => params[:console_more].to_i).limit(1)
                    if @girls.present?
                      #girl = messages.first.sender
                      girl = @girls.first
                      if params[:msg].present?
                        params[:msg] = params[:msg].gsub(/(?:f|ht)tps?:\/[^\s]+/, t("link_removed"))
                        message = Message.create(recipient_id: girl.id, sender_id: current_user.id, body: params[:msg].gsub("'", '').gsub('"', ''))
                        message = t("message_sent_to", recipient: girl.name)
                      end
                    end  
                  else  
                    @girls = []
                  end  
                  girls_limit = 1
                else
                  girls_limit = (params[:console_find].to_i > 15) ? 15 : params[:console_find].to_i  
                  #@girls_near_city_country = User.where("(city LIKE '%#{current_user.city}%' OR country LIKE '%#{current_user.country}%') AND is_girl = ? AND is_active = ?", true, true)
                  if params[:page].present?
                    session[:page] = session[:page].present? ? (session[:page] + 1) : 2
                    @girls = girls.where(search_keys).paginate(:per_page => girls_limit, :page => session[:page])
                  else
                    @girls = girls.where(search_keys).paginate(:per_page => girls_limit, :page => 1)
                    session[:page] = nil
                  end
                  #@girls = @girls_near_city_country + @girls
                end  
              end
              
              @girls, ratio_hash = matching_ratio_girls @girls, girls_limit 
              
              i = 1
              @girls.each do |k, girl|
                if params[:console_more].present?
                  profile_image = girl.avatar.exists? ? girl.avatar(:medium) : "girl-default.png"
                  girls_data = girls_data + render_to_string(:partial => 'programmers/find', :layout => false, :locals => {:girl => girl, :i => i, :ratio_hash => ratio_hash, :k => k})
                else
                  girls_data = girls_data + render_to_string(:partial => 'programmers/find', :layout => false, :locals => {:girl => girl, :i => i, :ratio_hash => ratio_hash, :k => k})
                end
                i = i + 1
              end
            end
            if params[:msg].present?
              render :text => message.present? ? message : t("recipient_not_found")
            else
              render :text => girls_data.present? ? girls_data : t("no_girls_found")
            end  
        end
      else
        render :text => t("please_select_a_skill_to_unlock_database")
      end  
    else
      render :text => t("please_complete_profile_to_find_girl")
    end
    
  end  
  
  def skills
    if params[:id].present?
      skill = Skill.find_by_id(params[:id].to_i)
      if skill
        skill_questions = skill.skill_questions.locale(@language.id).order("id asc")
        if skill_questions.first
          session[:console_skill_id] = skill.id
          session[:console_skill_question_count] = 0
          session[:console_skill_question_id] = skill_questions.first.id
          skill_set_data = { question: "#{t('please_confirm_you_are_a_prog')}:\n#{skill_questions.first.question}", answer: "Your answer (please type) -> ", msg: "" }
          render :json => skill_set_data.to_json
        else
          current_user.skill_id = skill.id
          current_user.is_girl = false
          current_user.save
          
          #increase battery
          #battery_charge_discharge(current_user, "pass_test")
          
          skill_name = t(skill.name.gsub(" ", "_").downcase)
          google_analytics("console", "unlock-passed")
          skill_set_data = { msg: t("skill_set_to_profile", skill: skill_name) }
          render :json => skill_set_data.to_json
        end
      else
        skill_set_data = { msg: t("skill_not_found") }
        render :json => skill_set_data.to_json
      end  
    else
      skills = Skill.all
      skills_data = ''
      skills.each_with_index do |skill, k|
        skill_name = t(skill.name.gsub(" ", "_").downcase)
        skills_data = skills_data + "#{skill.id}. #{skill_name}\n"
      end   
      
      if current_user.skill
        skill_name = t(current_user.skill.name.gsub(" ", "_").downcase)
        skills_data = skills_data + "\n#{t('your_current_prog_lang', skill: skill_name)}"
      end  
      
      google_analytics("console", "unlock")
      skills_data = skills_data + "\nunlock N - to unlock a programming language"
      render :text => skills_data
    end  
  end

  def skill_question_answers
    if params[:answer].present? && session[:console_skill_id].present?
      skill_question = SkillQuestion.find(session[:console_skill_question_id])
      if "'#{skill_question.answer.strip}'".to_s.downcase["'#{params[:answer].strip}'".to_s.downcase]
        skill = Skill.find(session[:console_skill_id].to_i)
        if session[:console_skill_question_count]
          if session[:console_skill_question_count].to_i == 2
            current_user.skill_id = skill.id
            current_user.is_girl = false
            current_user.save
            
            #increase battery
            #battery_charge_discharge(current_user, "pass_test")
            
            skill_name = t(skill.name.gsub(" ", "_").downcase)
            google_analytics("console", "unlock-passed")
            skill_set_data = { msg: t("skill_set_to_profile", skill: skill_name) }
            session[:console_skill_question_count] = session[:console_skill_question_id] = session[:console_skill_id] = nil
            render :json => skill_set_data.to_json
          else
            skill_questions = skill.skill_questions.locale(@language.id).order("id asc")
            if skill_questions[session[:console_skill_question_count]]
              session[:console_skill_question_count] = session[:console_skill_question_count] + 1
              if skill_questions[session[:console_skill_question_count]].present?
                skill_set_data = { question: "#{t('correct')}\n#{skill_questions[session[:console_skill_question_count]].question}", answer: "Your answer (please type) -> ", msg: "" }
                session[:console_skill_question_id] = skill_questions[session[:console_skill_question_count]].id
                render :json => skill_set_data.to_json
              else
                current_user.skill_id = skill.id
                current_user.is_girl = false
                current_user.save
                
                #increase battery
                #battery_charge_discharge(current_user, "pass_test")
                
                skill_name = t(skill.name.gsub(" ", "_").downcase)
                google_analytics("console", "unlock-passed")
                skill_set_data = { msg: t("skill_set_to_profile", skill: skill_name) }
                session[:console_skill_question_count] = session[:console_skill_question_id] = session[:console_skill_id] = nil
                render :json => skill_set_data.to_json
              end
            else
              current_user.skill_id = skill.id
              current_user.is_girl = false
              current_user.save
              
              #increase battery
              #battery_charge_discharge(current_user, "pass_test")
              
              skill_name = t(skill.name.gsub(" ", "_").downcase)
              google_analytics("console", "unlock-passed")
              skill_set_data = { msg: t("skill_set_to_profile", skill: skill_name) }
              session[:console_skill_question_count] = session[:console_skill_question_id] = session[:console_skill_id] = nil
              render :json => skill_set_data.to_json
            end
          end
        else
          current_user.skill_id = skill.id
          current_user.is_girl = false
          current_user.save
          
          #increase battery
          #battery_charge_discharge(current_user, "pass_test")
          
          skill_name = t(skill.name.gsub(" ", "_").downcase)
          google_analytics("console", "unlock-passed")
          skill_set_data = { msg: t("skill_set_to_profile", skill: skill_name) }
          session[:console_skill_question_count] = session[:console_skill_question_id] = session[:console_skill_id] = nil
          render :json => skill_set_data.to_json
        end  
      else
        skill_set_data = { question: t("sorry_ans_wrong"), answer: "Your answer again (please type) -> ", msg: "" }
        render :json => skill_set_data.to_json
      end
    else
      skill_set_data = { msg: t("provide_ans_or_choose_prog_lang") }
      render :json => skill_set_data.to_json
    end
  end

  def programmer_profile
    if params[:profile].present?
      if params[:field].present?
        if params[:field] == "Name"
          current_user.update_attributes(:username => params[:val]) if params[:val].present?
          profile_field = { field: "Age: " }
          render :json => profile_field.to_json
        elsif params[:field] == "Age"
          current_user.update_attributes(:age => params[:val]) if params[:val].present?
          gender = current_user.gender == 1 ? t("male") : (current_user.gender == 2 ? t("female") : "nil")
          profile_field = { msg: t("current_gender_is", gender: gender), field: "Gender - type male or female: " }
          render :json => profile_field.to_json
        elsif params[:field] == "Gender - type male or female"
          if params[:val] == "male" || params[:val] == "female"
            params[:val] = (params[:val] == "male") ? 1 : 2
            current_user.update_attributes(:gender => params[:val]) if params[:val].present?
            profile_field = { field: "City: " }
          else
            profile_field = { msg: t("gender_wrong"), field: "Gender - type male or female: " }
          end
          render :json => profile_field.to_json
        elsif params[:field] == "City"
          current_user.update_attributes(:city => params[:val]) if params[:val].present?
          profile_field = { field: "Country - enter 2 letter country code: " }
          render :json => profile_field.to_json          
        elsif params[:field] == "Country - enter 2 letter country code"
          current_user.update_attributes(:country => params[:val].upcase) if params[:val].present?
          profile_field = { field: "Enable email notifications about new messages - set true or false: " }
          render :json => profile_field.to_json
        elsif params[:field] == "Enable email notifications about new messages - set true or false"
          if params[:val].present? && ["true", "false"].include?(params[:val])
            notification = (params[:val] == "true") ? true : false
            current_user.update_attributes(:notification => notification)
          end
          profile_field = { field: "AvatarURL - you may copy and paste: " }
          render :json => profile_field.to_json

        elsif params[:field] == "AvatarURL - you may copy and paste"

          begin
            if params[:val].present?
              u = params[:val].gsub("--", ";")
              match = []
              match = u.match(/data:(.*);base64,(.*)/)
              if match.present? && match[1].present?
                case match[1]
                when "image/gif"
                  file_name = "avatar#{current_user.id}.gif"
                  x = Base64.decode64(u['data:image/gif;base64,'.length .. -1])
                when "image/png"
                  file_name = "avatar#{current_user.id}.png"
                  x = Base64.decode64(u['data:image/png;base64,'.length .. -1])
                when "image/jpeg"
                  file_name = "avatar#{current_user.id}.jpeg"
                  x = Base64.decode64(u['data:image/jpeg;base64,'.length .. -1])                  
                when "image/jpg"
                  file_name = "avatar#{current_user.id}.jpg"
                  x = Base64.decode64(u['data:image/jpg;base64,'.length .. -1])
                else
                  file_name = ''
                end
                if file_name.present?
                  tmp_file = File.open("#{Rails.root}/tmp/#{file_name}",'wb'){ |file| file.write x}
                  sleep 1
                  current_user.avatar = File.open("#{Rails.root}/tmp/#{file_name}")
                  current_user.save
                  File.delete("#{Rails.root}/tmp/#{file_name}")
                  profile_field = { msg: t('avatar_uploaded_successfully'), field: "About Me: " }
                else
                  profile_field = { msg: t('avatar_not_uploaded'), field: "About Me: " }
                end
              else
                begin
                  current_user.update_attributes(:avatar => URI.parse(params[:val].strip))
                  profile_field = { msg: t('avatar_uploaded_successfully'), field: "About Me: " }                  
                rescue Exception => e
                  profile_field = { msg: t('avatar_not_uploaded'), field: "About Me: " }
                end
              end  
            else
              profile_field = { field: "About Me: " }  
            end
          rescue Exception => e
            profile_field = { msg: t('avatar_not_uploaded'), field: "About Me: " }
          end  

          render :json => profile_field.to_json 

        elsif params[:field] == "About Me"
          current_user.update_attributes(:about_me => params[:val]) if params[:val].present?
          profile_field = { field: "Password: " }
          render :json => profile_field.to_json
        elsif params[:field] == "Password"
          if params[:val].present? && params[:val].length >= 4
            current_user.update_attributes(:password => params[:val], :password_confirmation => params[:val])
            sign_in current_user, :bypass => true
          end
            
          if params[:val].present? && params[:val].length < 4
            profile_field = { msg: t("password_wrong"), field: "Password: " }
            render :json => profile_field.to_json
          else
            profile_image = current_user.avatar.exists? ? current_user.avatar(:thumb) : "/assets/boy-default.jpeg"
            profile_data = "\n#{t('profile_updated_successfully')}\n\n<table width='100%'><tr><td width='10%'><img src='#{profile_image}' width='100' height='100' /></td><td valign='top' width='90%'>#{t('username')} #{current_user.username}<br />#{t('age')} #{current_user.age}<br />#{t('city')} #{current_user.city}<br />#{t('country')} #{current_user.country}<br />#{t('about_me')} #{current_user.about_me}</td></tr></table>\n"          
            profile_data = { msg: profile_data}
            render :json => profile_data.to_json
          end  
        else
          profile_field = { msg: t("command_wrong") }
          render :json => profile_field.to_json          
        end      
      else  
        profile_field = { field: "Name: " }
        render :json => profile_field.to_json 
      end  
    else
      profile_image = current_user.avatar.exists? ? current_user.avatar(:thumb) : "/assets/boy-default.jpeg"
      profile_data = "\n<table width='100%'><tr><td width='10%'><img src='#{profile_image}' width='100' height='100' /></td><td valign='top' width='90%'>#{t('username')} #{current_user.username}<br />#{t('age')} #{current_user.age}<br />#{t('city')} #{current_user.city}<br />#{t('country')} #{current_user.country}<br />#{t('about_me')} #{current_user.about_me}</td></tr></table>\n"
      render :text => profile_data
    end
  end

  def remote_file_exists?(url)
    begin
      url = URI.parse(url)
      Net::HTTP.start(url.host, url.port) do |http|
        return http.head(url.request_uri)['Content-Type'].start_with? 'image'
      end
   rescue
     false
     end   
  end
  
  private
  
  def set_default_locale
    if params[:msg].present? 
      session[:lang] = "ru"
      I18n.locale = session[:lang]
    end    
  end
  
  #fetch chat users
  def fetch_messages page
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
