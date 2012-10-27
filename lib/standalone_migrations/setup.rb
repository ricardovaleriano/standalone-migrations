class StandaloneMigrations::Setup
  def configure_railtie
    environment
    require railtie_app_path
    paths
  end

  private
  def railtie_app_path
    path = "standalone_migrations/minimal_railtie_config"
    lib_path = File.expand_path "../..", __FILE__
    @railtie_app_path ||= File.join lib_path, path
  end

  def environment
    if environment = ENV["DB"] || ENV["RACK_ENV"]
      ENV["RAILS_ENV"] = environment
    else
      ENV["RAILS_ENV"] = "development"
    end
    ENV["RAILS_ENV"]
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
