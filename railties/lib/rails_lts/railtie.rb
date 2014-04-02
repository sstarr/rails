require 'rails_lts'

module RailsLts

  class Railtie < Rails::Railtie
    config.rails_lts_options = {}


    config.before_initialize do |app|
      RailsLts.configuration = Configuration.new(app.config.rails_lts_options)
    end

    config.after_initialize do
      RailsLts.finalize
    end

  end

end
