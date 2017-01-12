class AdminNotificationMailer < ActionMailer::Base
  default :from => "'#{I18n.t('dateprog')}' <no-reply@demo.com>"
  default :to => "'Admin' <rahulvi.dev@gmail.com>"
  
 def send_new_course_published(course, user)
    @course = course
    @user = user
    # sending notifications
    mail(subject: "COURSE #{@course.id}: need approval: #{@course.title} by #{@user.name}")
 end  

 def send_new_course_unpublished(course, user)
    @course = course
    @user = user
    # sending notifications
    mail(subject: "COURSE #{@course.id}: need approval: #{@course.title} by #{@user.name}")
 end  


 def send_new_job_published(job, user)
    @job = job
    @user = user
    # sending notifications
    mail(subject: "JOB #{@job.id}: need approval: #{@job.title} by #{@user.name}")
 end   

 def send_new_job_unpublished(job, user)
    @job = job
    @user = user
    # sending notifications
    mail(subject: "JOB #{@job.id}: unpublished: #{@job.title} by #{@user.name}")
 end   


end
