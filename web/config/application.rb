unless File.exist?(File.expand_path('../secrets.yml', __FILE__))
  fail 'Please create config/secrets.yml.'
end
require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'rails/test_unit/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GoingPostalWeb
  class Application < Rails::Application
    # Settings in environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations
    # from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path +=
    #   Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.logger = Logger.new(STDOUT)

    config.action_mailer.default_url_options = {host: 'localhost', port: 3000}

    config.action_controller.action_on_unpermitted_parameters = :raise
  end
end
