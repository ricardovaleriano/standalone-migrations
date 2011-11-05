module StandaloneMigrations
  module NamespacedTasks
    module Helper

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

      def prefix
        "omg_my_awesome_dir"
      end

      def temp_dir
        File.join(File.expand_path("../", __FILE__), "tmp")
      end

      def prepare_subprojects
        @original_dir = Dir.pwd
        FileUtils.mkdir_p(temp_dir) unless File.directory?(temp_dir)
        Dir.chdir(temp_dir)
        create_directories
      end

      def destroy_subprojects
        FileUtils.rm_rf(temp_dir)
        Dir.chdir(@original_dir)
      end

    end
  end
end
