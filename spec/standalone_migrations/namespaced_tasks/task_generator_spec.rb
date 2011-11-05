require_relative 'helper'

module StandaloneMigrations

  module NamespacedTasks

    describe TaskGenerator, "generate tasks for each subdir with a .standalone_migrations file" do
      include Helper

      let(:generator) do
        TaskGenerator.new
      end

      before(:all) do
        prepare_subprojects
      end

      context "tasks/[namespace]_tasks.rb" do

        it "create the tasks/ dir" do
          File.directory?("tasks").should be_false
          generator.generate_for_all_found_subprojects
          File.directory?("tasks").should be_true
        end

        it "create an [namespace]_tasks.rb for each subproject" do
          generator.generate_for_all_found_subprojects
          p Dir.glob("tasks/*_tasks.rb")
        end

        after(:each) do
          FileUtils.rm_rf("tasks")
        end

      end

      it "add a load line in the Rakefile after create a subdir specific task file" do
        pending " echo 'load tasks/*' >> Rakefile"

        # quando rodar uma task dentro de um namespace tem que carregar o config
        # específico daquele namespace
      end

      after(:all) do
        destroy_subprojects
      end

    end
  end
end
