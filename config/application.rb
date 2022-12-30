require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FirstPrototype
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  
  # Set time zone to Eastern Standard Time
  # We assume all users are in the same time zone since they are all on a campus
  # Dealing with mixed time zones in rails is difficult
  config.time_zone = "Eastern Time (US & Canada)"

  end
end
