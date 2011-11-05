module StandaloneMigrations

  module NamespacedTasks

    class Discoverer

      def subdirs_config_file
        Dir.glob("*/**/.standalone_migrations")
      end

    end

  end
end
