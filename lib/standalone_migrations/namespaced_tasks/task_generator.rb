module StandaloneMigrations

  module NamespacedTasks

    class TaskGenerator

      def generate_for_all_found_subprojects
        create_tasks_dir
        configurators = subprojects_configurators
        p configurators
      end

      private

      def create_tasks_dir
        FileUtils.mkdir_p "tasks" unless File.directory? "tasks"
      end

      def subprojects_configurators
        subprojects_configuration = Discoverer.new.dirs_with_config_file
        subprojects_configuration.map do |config_path|
          "um configurator para cada arquivo de configuracao existente #{config_path}"
        end
      end

    end

  end
end
