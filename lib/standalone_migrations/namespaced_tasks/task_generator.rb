module StandaloneMigrations

  module NamespacedTasks

    class TaskGenerator

      def generate_for_all_found_subprojects
        FileUtils.mkdir_p "tasks" unless File.directory? "tasks"
      end

    end

  end
end
