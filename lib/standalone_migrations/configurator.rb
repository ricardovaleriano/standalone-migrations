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
      if @config_for[environment]
        return @config_for[environment]
      end
      config_for_all[environment]
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

  end
end
