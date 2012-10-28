require 'yaml'

def tmp_db_dir
  "tmp/db"
end

module StandaloneMigrations
  describe Configurator, "which allows define custom dirs and files to work with your migrations" do

    describe "environment yaml configuration loading" do
      let(:multi_db_env) { "multiple_db_environment" }
      let(:multi_db_env_abs) { "multiple_db_environment_abs" }

      let(:env_hash) do
        {
          "development" => {
            "adapter" => "sqlite3",
            "database" => "db/development.sqlite"},

          "test" => {
            "adapter" => "sqlite3",
            "database" => "db/test.sqlite"},

          "production" => {
            "adapter" => "sqlite3",
            "database" => ":memory:"},

          multi_db_env => {
            "adapter" => "sqlite3",
            "database" => "db/mult_db_env.sqlite"},

          multi_db_env_abs => {
            "adapter" => "sqlite3",
            "database" => "/db/mult_db_env.sqlite"},
        }
      end

      before(:all) do
        @original_dir = Dir.pwd
        Dir.chdir( File.expand_path("../../", __FILE__) )
        FileUtils.mkdir_p tmp_db_dir
        Dir.chdir "tmp"
        File.open("db/config.yml", "w") do |f|
          f.write env_hash.to_yaml
        end
      end

      it "load the specific environment config" do
        config = Configurator.new.config_for(:development)
        config.should == env_hash["development"]
      end

      it "load the yaml with environment configurations" do
        config = Configurator.new.config_for(:development)
        config[:database].should == env_hash["development"]["database"]
      end

      it "allow access the original configuration hash (for all environments)" do
        Configurator.new.config_for_all.should == env_hash
      end

      context "customizing the environments configuration dynamically" do

        let(:configurator) { Configurator.new }
        let(:new_config) { { 'sbrobous' => 'test' } }

        it "allow changes on the configuration hashes" do
          configurator.environments_config do |env|
            env.on("production") { new_config }
          end
          configurator.config_for("production").should == new_config
        end

        it "return current configuration if block yielding returns nil" do
          configurator.environments_config do |env|
            env.on "production" do
              nil
            end
          end
          configurator.config_for("production").should == new_config
        end

        it "pass the current configuration as block argument" do
          configurator.environments_config do |env|
            env.on "production" do |current_config|
              current_config.should == new_config
            end
          end
        end

      end

      context "With StandaloneMigrations::alternative_root_db_path set" do
        let(:alternative_root) { "db/some" }
        let(:alternative_path) { "#{alternative_root}/alternative/path" }
        let(:alternative_db) { "#{alternative_path}/db" }
        let(:railtie) { Class.new(Rails.application.class) }
        let(:configurator) { Configurator.new railtie: railtie }
        let(:non_in_memory) { env_hash[multi_db_env] }
        let(:absolute_path) { File.join Dir.pwd, alternative_path }
        let(:database_path) { File.join absolute_path, non_in_memory["database"] }

        before(:all) do
          FileUtils.mkdir_p alternative_db unless
              File.exist?(alternative_db)
          File.open("#{alternative_db}/config.yml", 'w') do |f|
            f.write env_hash.to_yaml
          end
          StandaloneMigrations.alternative_root_db_path = alternative_path
        end

        it "should load config from file from the correct path" do
          config = configurator.config_for(:development)
          config[:database].should include env_hash["development"]["database"]
        end

        context "When using sqlite database" do
          describe "append an absolute path if" do
            context "a non 'in memory' database is configured and..." do
              it "a non absolute path was given" do
                config = configurator.config_for(multi_db_env)
                config[:database].should == database_path
              end

              it "only if a non absolute path was given" do
                config = configurator.config_for(multi_db_env_abs)
                config[:database].should == env_hash[multi_db_env_abs]["database"]
              end
            end
          end
        end# sqlite database

        after(:all) do
          StandaloneMigrations.alternative_root_db_path = nil
          FileUtils.rm_rf alternative_db
        end
      end

      after(:all) do
        Dir.chdir @original_dir
      end

    end

    context "default values when .standalone_configurations is missing" do

      let(:configurator) do
        Configurator.new
      end

      it "use config/database.yml" do
        configurator.config.should == 'db/config.yml'
      end

      it "use db/migrate dir" do
        configurator.migrate_dir.should == 'db/migrate'
      end

      it "use db/seeds.rb" do
        configurator.seeds.should == "db/seeds.rb"
      end

      it "use db/schema.rb" do
        configurator.schema.should == "db/schema.rb"
      end

    end

    context "passing configurations as a parameter" do
      let(:args) do
        {
          :config       => "custom/config/database.yml",
          :migrate_dir  => "custom/db/migrate",
          :seeds        => "custom/db/seeds.rb",
          :schema       => "custom/db/schema.rb"
        }
      end

      let(:configurator) do
        Configurator.new args
      end

      it "use custom config" do
        configurator.config.should == args[:config]
      end

      it "use custom migrate dir" do
        configurator.migrate_dir.should == args[:migrate_dir]
      end

      it "use custom seeds" do
        configurator.seeds.should == args[:seeds]
      end

      it "use custom schema" do
        configurator.schema.should == args[:schema]
      end

    end

    context "using a .standalone_migrations file with configurations" do

      before(:all) do
        @original_dir = Dir.pwd
        Dir.chdir File.expand_path("../", __FILE__)
      end

      let(:yaml_hash) do
        {
          "db" => {
            "seeds"    => "file/db/seeds.rb",
            "migrate"  => "file/db/migrate",
            "schema"   => "file/db/schema.rb"
          },
          "config" => {
            "database" => "file/config/database.yml"
          }
        }
      end

      let(:configurator) do
        file = ".standalone_migrations"
        File.open(file, "w") { |file| file.write(yaml_hash.to_yaml) }

        Configurator.new
      end

      context "with some configurations missing" do

        let(:yaml_hash) do
          {
            "config" => {
              "database" => "file/config/database.yml"
            }
          }
        end

        it "use default values for the missing configurations" do
          configurator.migrate_dir.should == 'db/migrate'
        end

        it "use custom config from file" do
          configurator.config.should == yaml_hash["config"]["database"]
        end
      end

      it "use custom config from file" do
        configurator.config.should == yaml_hash["config"]["database"]
      end

      it "use custom migrate dir from file" do
        configurator.migrate_dir.should == yaml_hash["db"]["migrate"]
      end

      it "use custom seeds from file" do
        configurator.seeds.should == yaml_hash["db"]["seeds"]
      end

      it "use custom schema from file" do
        configurator.schema.should == yaml_hash["db"]["schema"]
      end

      after(:all) do
        File.delete ".standalone_migrations"
        Dir.chdir @original_dir
      end

    end
  end
end
