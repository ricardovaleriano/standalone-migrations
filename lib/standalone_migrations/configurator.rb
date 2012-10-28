require 'active_support/all'

module StandaloneMigrations

  class Configurator

    def self.load_configurations(configurator = nil)
      @standalone_configs ||= configurator ? configurator.config : Configurator.new.config
      if !@environments_config
        erbfied = ERB.new(File.read(@standalone_configs)).result
        @environments_config = YAML.load(erbfied).with_indifferent_access
      end
      @environments_config
    end

    def self.environments_config
      proxy = InternalConfigurationsProxy.new(load_configurations)
      yield(proxy) if block_given?
    end

    def initialize(options = {})
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
      Configurator.load_configurations(self).dup
    end

    def config_for(environment)
      config_for_all[environment]
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

  class InternalConfigurationsProxy

    def initialize(configurations)
      @configurations = configurations
    end

    def on(config_key)
      if @configurations[config_key] && block_given?
        @configurations[config_key] = yield(@configurations[config_key]) || @configurations[config_key]
      end
      @configurations[config_key]
    end

  end #InternalConfigurationsProxy
end
