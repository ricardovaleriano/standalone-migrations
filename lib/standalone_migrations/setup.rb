class StandaloneMigrations::Setup
  def environment
    if !ENV["RAILS_ENV"]
      ENV["RAILS_ENV"] = ENV["DB"] || ENV["RACK_ENV"] || "development"
    end
  end

  def railtie_app_path
    path = "standalone_migrations/minimal_railtie_config"
    lib_path = File.expand_path "../..", __FILE__
    @railtie_app_path ||= File.join lib_path, path
  end

  def paths
    if StandaloneMigrations.alternative_root_db_path
      Rails.application.paths["db/migrate"] = [StandaloneMigrations.alternative_root_db_path]
    end
  end
end
