require 'yaml'
require_relative 'helper'

module StandaloneMigrations

  module NamespacedTasks

    describe Discoverer, "search for .standalone_migration files on subdirs relatively to Rakefile location" do
      include Helper

      context "4 subdirs with configuration file among 6 on total" do

        let(:discoverer) do
          Discoverer.new
        end

        before(:all) do
          prepare_subprojects
        end

        it "should found 4 subdirs" do
          dirs = discoverer.subdirs_config_file
          dirs.size.should == 4
        end

        it "should found only dirs with configuration" do
          dirs = discoverer.subdirs_config_file
          (1..4).each do |config_num|
            dir = "#{prefix}#{config_num}"
            config_file = File.join(dir, ".standalone_migrations")
            dirs.should include config_file
          end
        end

        after(:all) do
          destroy_subprojects
        end

      end

    end
  end
end
