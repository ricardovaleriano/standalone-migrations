class StandaloneMigrations::Setup
  def environment
    if !ENV["RAILS_ENV"]
      ENV["RAILS_ENV"] = ENV["DB"] || ENV["RACK_ENV"] || "development"
    end
    ENV["RAILS_ENV"]
  end

  def railtie_app_path
    path = "standalone_migrations/minimal_railtie_config"
    lib_path = File.expand_path "../..", __FILE__
    @railtie_app_path ||= File.join lib_path, path
  end

  def configure_railtie
    environment
    require "standalone_migrations/minimal_railtie_config"
    paths
  end

  def paths
    if StandaloneMigrations.alternative_root_db_path
      @db_migrate_path = Rails.application.paths["db/migrate"]
      Rails.application.paths["db/migrate"] = [StandaloneMigrations.alternative_root_db_path]
    end
    Rails.application.paths["db/migrate"]
  end

  def restore_originals
    if Rails.application.paths["db/migrate"] && @db_migrate_path
      Rails.application.paths["db/migrate"] = @db_migrate_path
    end
  end
end
