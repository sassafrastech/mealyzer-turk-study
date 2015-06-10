require 'environs'
require 'dotenv'

require File.expand_path('../boot', __FILE__)

require 'rails/all'
Dotenv.load ".env.#{Rails.env}", ".env"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module MealyzerStudy
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

    # allow for localhost ssl
    config.use_ssl = false

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*',
         :headers => :any,
         :expose  => ['access-token', 'expiry', 'token-type', 'uid', 'client'],
         :methods => [:get, :post, :delete, :put, :options]
      end
    end

    config.action_mailer.delivery_method = Env.mealyzer_mail_delivery_method(allow_nil: true).to_sym
    config.action_mailer.smtp_settings = {
      :address              => Env.mealyzer_smtp_host_address(allow_nil: true),
      :port                 => Env.mealyzer_smtp_host_port(allow_nil: true).try(:to_i),
      :domain               => Env.mealyzer_smtp_host_domain(allow_nil: true),
      :user_name            => Env.mealyzer_smtp_host_user_name(allow_nil: true),
      :password             => Env.mealyzer_smtp_host_password(allow_nil: true),
      :authentication       => Env.mealyzer_smtp_host_authentication(allow_nil: true).try(:to_sym),
      :enable_starttls_auto => Env.mealyzer_smtp_host_enable_starttls(allow_nil: true) == "true"
    }
  end
end
