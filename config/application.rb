require_relative "boot"

require "rails/all"
Bundler.require(*Rails.groups)

module NumarisChallenge
  class Application < Rails::Application
    config.load_defaults 7.2

    config.autoload_lib(ignore: %w[assets tasks])

    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]
    config.i18n.available_locales = [ :en, :es ]
    config.i18n.default_locale = :es
  end
end
