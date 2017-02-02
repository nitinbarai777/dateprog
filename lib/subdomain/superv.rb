module Subdomain
  class Superv
    def self.matches?(request)
      request.subdomain.split('.').first == 'superv'
    end
  end
end