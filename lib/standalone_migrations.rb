lib_path = File.expand_path("../", __FILE__)
$:.unshift lib_path unless $:.include?(lib_path)

require "rubygems"
require "rails"
require "active_record"

module StandaloneMigrations
  # TODO: add a if !defined? mattr_accessor here
  # and give an alternative implementation to this method
  # since it's brought to us by active_support which
  # is a dependency of active_record and not of
  # standalone_migrations.
  # Ricardo Valeriano
  mattr_accessor :alternative_root_db_path
  db_path = ENV["db_path"] || ENV["DB_PATH"]
  StandaloneMigrations.alternative_root_db_path = db_path
end

require "standalone_migrations/configurator"
require "standalone_migrations/generator"
require "standalone_migrations/setup"

setup = StandaloneMigrations::Setup.new
setup.environment

APP_PATH = setup.railtie_app_path
require "standalone_migrations/minimal_railtie_config"

setup.paths
require "standalone_migrations/tasks"
