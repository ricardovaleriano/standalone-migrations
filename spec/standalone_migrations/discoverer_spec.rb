require 'spec_helper'
require 'yaml'

module StandaloneMigrations

  describe Discoverer, "search for .standalone_migration files on subdirs relatively to Rakefile location" do
    def config_yaml
      "im:emptpy_for_now"
    end

    def create_config(dir)
      File.open(File.join(dir, ".standalone_migrations"), "w") do |config|
        config << config_yaml
      end
    end

    def create_directories(total=6, with_config=4)
      (1..total).each do |dir_num|
        dir_name = "#{prefix}#{dir_num.to_s}"
        FileUtils.mkdir_p(dir_name)
        if dir_num <= with_config
          create_config(dir_name)
        end
      end
    end

    context "4 subdirs with configuration file among 6 on total" do

      let(:discoverer) do
        Discoverer.new
      end

      let(:temp_dir) do
        File.join(File.expand_path("../", __FILE__), "tmp")
      end

      let(:prefix) do
        "omg_my_awesome_dir"
      end

      before(:all) do
        @original_dir = Dir.pwd
        FileUtils.mkdir_p(temp_dir) unless File.directory?(temp_dir)
        Dir.chdir(temp_dir)
        create_directories
      end

      it "found 4 subdirs" do
        dirs = discoverer.dirs_with_config_file
        dirs.size.should == 4
      end

      it "found only dirs with configuration" do
        dirs = discoverer.dirs_with_config_file
        (1..4).each do |config_num|
          dir = "#{prefix}#{config_num}"
          config_file = File.join(dir, ".standalone_migrations")
          dirs.should include config_file
        end
      end

      after(:all) do
        FileUtils.rm_rf(temp_dir)
        Dir.chdir(@original_dir)
      end

    end

  end
end
