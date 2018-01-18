require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TripCompare
  class Application < Rails::Application
    config.action_controller.permit_all_parameters = true
    config.time_zone = 'Eastern Time (US & Canada)'

    ENV['GOOGLE_PLACES_API_KEY'] = 'test'
    ENV['VERSION'] = `git --git-dir="#{Rails.root.join(".git")}" --work-tree="#{Rails.root}" log -1 --date=short --format="%ad-%h"|sed 's/-/./g'`


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
