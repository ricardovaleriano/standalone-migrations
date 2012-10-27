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
end

require "standalone_migrations/setup"
require "standalone_migrations/configurator"
require "standalone_migrations/generator"
require "standalone_migrations/tasks"
