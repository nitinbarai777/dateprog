module Subdomain
  class Site
    def self.matches?(request)
      if request.subdomain.present? and request.subdomain != "superv" and request.subdomain != "admin"
        AdminUser.find_by subdomain: request.subdomain
      end
      # request.subdomain.empty? or not AdminUser.where(:subdomain => request.subdomain).include? request.subdomain.split('.')[0].to_sym
    end
  end
end