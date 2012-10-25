# these generators are backed by rails' generators
require "rails/generators"
module StandaloneMigrations
  class Generator
    def self.destination_root
      destination_root = Rails.root
      if StandaloneMigrations.alternative_root_db_path
        destination_root = File.join Rails.root, StandaloneMigrations.alternative_root_db_path
      end
      destination_root
    end

    def self.migration(name, options="")
      generator_params = [name] + options.split(" ")
      Rails::Generators.invoke "active_record:migration", generator_params,
        destination_root: destination_root
    end
  end
end
