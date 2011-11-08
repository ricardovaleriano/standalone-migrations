require_relative 'helper'
require 'rake'
require 'yaml'

module StandaloneMigrations

  module NamespacedTasks

    describe TaskGenerator, "generate tasks for each subdir with a .standalone_migrations file" do
      include Helper

      def standalone_migrations_path
        File.expand_path("../../../../lib/tasks/standalone_migrations.rb", __FILE__)
      end

      def generate_rakefile
        File.open("Rakefile", "w") do |rakefile|
          rakefile << "require '#{standalone_migrations_path}'\n"
        end
      end

      def destroy_rakefile
        destroy_standalone_configuration
        File.delete("Rakefile")
      end

      def database_config
        {"test" => {"adapter" => "sqlite3", "database" => ":memory:"}}
      end

      def create_standalone_configuration
        FileUtils.mkdir_p "db"
        File.open("db/config.yml", "w") do |config|
          config << database_config.to_yaml
        end
      end

      def destroy_standalone_configuration
        FileUtils.rm_rf "db"
      end

      def load_rakefile
        generate_rakefile
        create_standalone_configuration
        load "Rakefile"
      end

      let(:generator) do
        TaskGenerator.new
      end

      before(:all) do
        prepare_subprojects
        load_rakefile
      end

      context "tasks/[namespace]_tasks.rb creation" do

        it "create the tasks/ dir" do
          File.directory?("tasks").should be_false
          generator.generate_for_all_found_subprojects
          File.directory?("tasks").should be_true
        end

        it "create a task file to each subproject" do
          generator.generate_for_all_found_subprojects
          Dir.glob("tasks/*_tasks.rb").size.should == 4
        end

        it "create an [namespace]_tasks.rb for each subproject" do
          generator.generate_for_all_found_subprojects
          expected_files = Discoverer.new.subdirs_config_file.map do |config|
            subproject_dir = File.expand_path("../", config)
            "tasks/" << Pathname.new(subproject_dir).basename.to_s << "_tasks.rb"
          end

          Dir.glob("tasks/*_tasks.rb").should == expected_files
        end

        it "load namespaced tasks within the regular Rakefile" do
          puts """uma boa ideia pra botar namespace so nas que interessam
          eh carregar na memoria somente as migrations do standalone e ai 
          namespacear todas elas =)"""

          namespaced = []
          only_db = Rake.application.tasks.select { |task| task.name.index "db:" }
          Discoverer.new.subdirs_config_file.each do |config|
            subproject_dir = File.expand_path("../", config)
            dir_name = Pathname.new(subproject_dir).basename.to_s
            namespaced << only_db.map do |task|
              "db:#{dir_name}:#{task.name[3, task.name.length]}"
            end
          end

          p namespaced
          pending " echo 'load tasks/*' >> Rakefile"

          # quando rodar uma task dentro de um namespace tem que carregar o config
          # específico daquele namespace
        end

        after(:each) do
          FileUtils.rm_rf("tasks")
        end

      end

      after(:all) do
        destroy_rakefile
        destroy_subprojects
      end

    end
  end
end
