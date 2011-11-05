module StandaloneMigrations

  module NamespacedTasks

    describe TaskGenerator, "generate tasks for each subdir with a .standalone_migrations file" do
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

      let(:prefix) do
        "omg_my_awesome_dir"
      end

      let(:temp_dir) do
        File.join(File.expand_path("../", __FILE__), "tmp")
      end

      let(:generator) do
        TaskGenerator.new
      end

      before(:all) do
        @original_dir = Dir.pwd
        FileUtils.mkdir_p(temp_dir) unless File.directory?(temp_dir)
        Dir.chdir(temp_dir)
        create_directories
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
        FileUtils.rm_rf(temp_dir)
        Dir.chdir(@original_dir)
      end

    end
  end
end
