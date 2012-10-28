module StandaloneMigrations
  class Tasks
    class << self
      def load_standalone_migration_tasks
        %w(
          connection
          environment
          db/new_migration
        ).each do
          |task| load "standalone_migrations/tasks/#{task}.rake"
        end
      end

      def load_tasks
        Deprecations.new.call

        configurator = Configurator.new
        configurator.configure

        MinimalRailtieConfig.load_tasks
        load_standalone_migration_tasks

        load "active_record/railties/databases.rake"
      end
    end
  end

  class Tasks::Deprecations
    def call
      if File.directory?('db/migrations')
        puts "DEPRECATED move your migrations into db/migrate"
      end
    end
  end
end
