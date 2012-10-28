require 'active_support/all'

module StandaloneMigrations

  class Configurator
    def initialize(options = {})
      @config_for = {}

      path = root_db_path
      defaults = {
        :config       => File.join(path, "config.yml"),
        :migrate_dir  => File.join(path, "migrate"),
        :seeds        => File.join(path, "seeds.rb"),
        :schema       => File.join(path, "schema.rb")
      }
      @options = load_from_file(defaults.dup) || defaults.merge(options)
      ENV['SCHEMA'] = schema
    end

    def environments_config
      yield(self) if block_given?
    end

    def configure
      railtie = @options.delete(:railtie)
      setup = StandaloneMigrations::Setup.new railtie
      @railtie = setup.configure_railtie
      configure_paths
    end

    def root_db_path
      path = "db"
      if StandaloneMigrations.alternative_root_db_path
        path = File.join(StandaloneMigrations.alternative_root_db_path, "db")
      end
      path
    end

    def config
      @options[:config]
    end

    def migrate_dir
      @options[:migrate_dir]
    end

    def seeds
      @options[:seeds]
    end

    def schema
      @options[:schema]
    end

    def config_for_all
      erbfied = ERB.new(File.read(config.dup)).result
      YAML.load(erbfied).with_indifferent_access
    end

    def config_for(environment)
      config = @config_for[environment] ? @config_for[environment] : config_for_all[environment]
      normalized_configuration_for config
    end

    def on(environment)
      if block_given? && current_config = config_for(environment)
        new_config = yield(current_config) || current_config
        @config_for[environment] = new_config
        return @config_for[environment]
      end
      config_for(environment)
    end

    private
    def normalized_configuration_for(config)
      is_non_memory_sqlite = config[:adapter] =~ /sqlite/ && config[:database] != ":memory:"
      need_absolute_path = is_non_memory_sqlite && StandaloneMigrations.alternative_root_db_path
      new_config = config.dup
      if need_absolute_path
        path = File.join Dir.pwd, StandaloneMigrations.alternative_root_db_path
        new_config[:database] = File.join path, config[:database]
      end
      new_config
    end

    def configuration_file
      default_file_name = ".standalone_migrations"
      alternative_path = StandaloneMigrations.alternative_root_db_path
      file = alternative_path ? File.join(alternative_path, default_file_name) : default_file_name
      file
    end

    def load_from_file(defaults)
      return unless File.exists?(configuration_file)
      config = YAML.load(IO.read(configuration_file))
      {
        :config       => config["config"] ? config["config"]["database"] : defaults[:config],
        :migrate_dir  => config["db"] ? config["db"]["migrate"] : defaults[:migrate_dir],
        :seeds        => config["db"] ? config["db"]["seeds"] : defaults[:seeds],
        :schema       => config["db"] ? config["db"]["schema"] : defaults[:schema]
      }
    end

    def configure_paths
      @railtie.config.paths.add "config/database", :with => config
    end

    def paths
      StandaloneMigrations.alternative_root_db_path = ENV["db_path"] || ENV["DB_PATH"]

      if StandaloneMigrations.alternative_root_db_path
        @db_migrate_path = Rails.application.paths["db/migrate"]
        Rails.application.paths["db/migrate"] = [StandaloneMigrations.alternative_root_db_path]
      end

      Rails.application.paths["db/migrate"]
    end

  end
end
