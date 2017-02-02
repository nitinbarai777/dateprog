module Subdomain
  class Admin
    def self.matches?(request)
      request.subdomain.split('.').first == 'admin'
      #AdminUser.find_by subdomain: request.subdomain
    end
  end
end
