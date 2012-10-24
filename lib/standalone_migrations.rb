lib_path = File.expand_path("../", __FILE__)
$:.unshift lib_path unless $:.include?(lib_path)

require "rubygems"
require "rails"
require "active_record"

require "standalone_migrations/configurator"
require "standalone_migrations/generator"
require "standalone_migrations/setup"

setup = StandaloneMigrations::Setup.new
setup.environment
APP_PATH = setup.railtie_app_path

require "standalone_migrations/minimal_railtie_config"
require "standalone_migrations/tasks"
