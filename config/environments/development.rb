Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # deleting Rack::Lock to speed up the page load time in Development env
  # according to http://nikolay.rocks/2015-08-06-unslow-rails-dev
  config.middleware.delete Rack::Lock

  # Do not eager load code on boot.
  config.eager_load = true # was changed from "false" according to http://nikolay.rocks/2015-08-06-unslow-rails-dev

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  
  # config.action_mailer.default_url_options = {:host => 'localhost:3007'}
  config.action_mailer.raise_delivery_errors = true
  #config.action_mailer.delivery_method = :letter_opener # commented as not working on c9.io
  config.action_mailer.delivery_method = :file
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { :host => "localhost" }
  
  # config.paperclip_defaults = {
  #   :storage => :s3,
  #   :s3_credentials => {
  #     :bucket => ENV["AWS_BUCKET"],
  #     :access_key_id => ENV["AWS_ACCESS_KEY_ID"],
  #     :secret_access_key => ENV["AWS_SECRET_ACCESS_KEY"]
  #   }
  # }
  
  FAYE_URL =  ENV['FAYE_ENDPOINT']

  BASE_URL = "http://localhost:3007/"
  BASE_URL_DOMAIN = "localhost:3007"

  
  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = false
   
  
  config.assets.compress = false

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

 config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  #config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 }

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address:        'smtp.gmail.com',
    port:           587,
    domain:         'gmail.com',
    user_name:      'rahulvi.dev',
    password:       'hvwptqjrzyesdbrz',
    authentication: 'plain',
    :enable_starttls_auto  => true
  }
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  
  # after initialize so we could get the digested image filename
  ActiveSupport.on_load(:after_initialize) do
    # lazyload gem config
    Lazyload::Rails.configure do |c|
      c.placeholder  = ActionController::Base.helpers.asset_path('grey.gif')
    end    
  end    
  
end
