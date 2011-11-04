module StandaloneMigrations

  class Discoverer

    def dirs_with_config_file
      Dir.glob("*/**/.standalone_migrations")
    end

  end
end
