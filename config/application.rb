require File.expand_path('../boot', __FILE__)

require 'rails/all'

#require 'rack/cors'


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dateprog
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  config.i18n.default_locale = :en

  config.autoload_paths += %W(#{config.root}/lib)
    
   config.middleware.insert_before ActionDispatch::Static, Rack::Cors do
     allow do
      origins '*'
      resource '*',
      headers: :any,
      methods: [:get, :options]
     end
   end
    # as advised in https://devcenter.heroku.com/articles/rails-4-asset-pipeline#known-issues
    config.serve_static_assets = true
    config.assets.initialize_on_precompile = true

    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif,
                                  "fontawesome-webfont.ttf",
                                 "fontawesome-webfont.eot",
                                 "fontawesome-webfont.svg",
                                 "fontawesome-webfont.woff")    
    
    
    config.middleware.delete Rack::Lock
    
    config.before_configuration do # FIX conflict I18n ActiveAdmin
      I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
      I18n.locale = I18n.default_locale = config.i18n.default_locale
      I18n.reload!
    end    
    
    config.action_dispatch.default_headers.merge!({
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Request-Method' => '*'
    })

    config.i18n.enforce_available_locales = true    
    
  end
end
