describe 'Standalone migrations' do
  before do
    prepare_tmp_project_dir
  end

  after(:all) do
    remove_tmp_project_dir
  end

  it "warns of deprecated folder structure" do
    warning = /DEPRECATED.* db\/migrate/
    run("rake db:create").should_not =~ warning
    write('db/migrations/fooo.rb', 'xxx')
    run("rake db:create").should =~ warning
  end

  describe 'db:create and drop' do
    it "should create the database and drop the database that was created" do
      # TODO: expectations? -- ricardo valeriano
      run "rake db:create"
      run "rake db:drop"
    end
  end

  describe 'db:new_migration' do
    it "fails if i do not add a name" do
      lambda{ run("rake db:new_migration") }.should raise_error(/name=/)
    end

    it "generates a new migration with this name from ENV and timestamp" do
      run("rake db:new_migration name=test_abc_env").should =~ %r{create(.*)db/migrate/\d+_test_abc_env\.rb}
      run("ls db/migrate").should =~ /^\d+_test_abc_env.rb$/
    end

    it "generates a new migration with this name from args and timestamp" do
      run("rake db:new_migration[test_abc_args]").should =~ %r{create(.*)db/migrate/\d+_test_abc_args\.rb}
      run("ls db/migrate").should =~ /^\d+_test_abc_args.rb$/
    end

    it "generates a new migration with the name converted to the Rails migration format" do
      run("rake db:new_migration name=MyNiceModel").should =~ %r{create(.*)db/migrate/\d+_my_nice_model\.rb}
      read(migration('my_nice_model')).should =~ /class MyNiceModel/
      run("ls db/migrate").should =~ /^\d+_my_nice_model.rb$/
    end

    it "generates a new migration with name and options from ENV" do
      run("rake db:new_migration name=add_name_and_email_to_users options='name:string email:string'")
      read(migration('add_name_and_email_to_users')).should =~ /add_column :users, :name, :string\n\s*add_column :users, :email, :string/
    end

    it "generates a new migration with name and options from args" do
      run("rake db:new_migration[add_website_and_username_to_users,website:string/username:string]")
      read(migration('add_website_and_username_to_users')).should =~ /add_column :users, :website, :string\n\s*add_column :users, :username, :string/
    end
  end

  describe 'db:version' do
    it "should start with a new database version" do
      run("rake db:version").should =~ /Current version: 0/
    end

    it "should display the current version" do
      run("rake db:new_migration name=test_abc")
      run("rake --trace db:migrate")
      run("rake db:version").should =~ /Current version: #{Time.now.year}/
    end
  end

  describe 'db:migrate' do
    it "does nothing when no migrations are present" do
      run("rake db:migrate").should_not =~ /Migrating/
    end

    it "migrates if i add a migration" do
      run("rake db:new_migration name=xxx")
      run("rake db:migrate").should =~ /Xxx: Migrating/i
    end
  end

  describe 'db:migrate:down' do
    it "migrates down" do
      make_migration('xxx')
      version = make_migration('yyy')
      run 'rake db:migrate'

      result = run("rake db:migrate:down VERSION=#{version}")
      result.should_not =~ /DOWN-xxx/
      result.should =~ /DOWN-yyy/
    end

    it "fails without version" do
      make_migration('yyy')
      lambda{ run("rake db:migrate:down") }.should raise_error(/VERSION/)
    end
  end

  describe 'db:migrate:up' do
    it "migrates up" do
      make_migration('xxx')
      run 'rake db:migrate'
      version = make_migration('yyy')
      result = run("rake db:migrate:up VERSION=#{version}")
      result.should_not =~ /UP-xxx/
      result.should =~ /UP-yyy/
    end

    it "fails without version" do
      make_migration('yyy')
      lambda{ run("rake db:migrate:up") }.should raise_error(/VERSION/)
    end
  end

  describe 'db:rollback' do
    it "does nothing when no migrations have been run" do
      run("rake db:version").should =~ /version: 0/
      run("rake db:rollback").should == ''
      run("rake db:version").should =~ /version: 0/
    end

    it "rolls back the last migration if one has been applied" do
      write_multiple_migrations
      run("rake db:migrate")
      run("rake db:version").should =~ /version: 20100509095816/
      run("rake db:rollback").should =~ /revert/
      run("rake db:version").should =~ /version: 20100509095815/
    end

    it "rolls back multiple migrations if the STEP argument is given" do
      write_multiple_migrations
      run("rake db:migrate")
      run("rake db:version").should =~ /version: 20100509095816/
      run("rake db:rollback STEP=2") =~ /revert/
      run("rake db:version").should =~ /version: 0/
    end
  end

  describe 'schema:dump' do
    it "dumps the schema" do
      write('db/schema.rb', '')
      run('rake db:schema:dump')
      read('db/schema.rb').should =~ /ActiveRecord/
    end
  end

  describe 'db:schema:load' do
    it "loads the schema" do
      run('rake db:schema:dump')
      schema = "db/schema.rb"
      write(schema, read(schema)+"\nputs 'LOADEDDD'")
      result = run('rake db:schema:load')
      result.should =~ /LOADEDDD/
    end

    it "loads all migrations" do
      make_migration('yyy')
      run "rake db:migrate"
      run "rake db:drop"
      run "rake db:create"
      run "rake db:schema:load"
      run( "rake db:migrate").strip.should == ''
    end
  end

  describe 'db:abort_if_pending_migrations' do
    it "passes when no migrations are pending" do
      run("rake db:abort_if_pending_migrations").strip.should == ''
    end

    it "fails when migrations are pending" do
      make_migration('yyy')
      lambda{ run("rake db:abort_if_pending_migrations") }.should raise_error(/1 pending migration/)
    end
  end

  describe 'db:test:load' do
    it 'loads' do
      write("db/schema.rb", "puts 'LOADEDDD'")
      run("rake db:test:load").should =~ /LOADEDDD/
    end

    it "fails without schema" do
      lambda{ run("rake db:test:load") }.should raise_error(/try again/)
    end
  end

  describe 'db:test:purge' do
    it "runs" do
      run('rake db:test:purge')
    end
  end

  describe "db:seed" do
    it "loads" do
      write("db/seeds.rb", "puts 'LOADEDDD'")
      run("rake db:seed").should =~ /LOADEDDD/
    end

    it "does nothing without seeds" do
      run("rake db:seed").length.should == 0
    end
  end

  describe "db:reset" do
    it "should not error when a seeds file does not exist" do
      make_migration('yyy')
      run('rake db:migrate DB=test')
      run("rake db:reset").should_not raise_error(/rake aborted/)
    end
  end

  describe 'db:migrate when environment is specified' do
    it "runs when using the DB environment variable" do
      make_migration('yyy')
      run('rake db:migrate DB=test')
      run('rake db:version DB=test').should_not =~ /version: 0/
      run('rake db:version').should =~ /version: 0/
    end

    it "should error on an invalid database" do
      lambda{ run("rake db:create DB=nonexistent")}.should raise_error(/rake aborted/)
    end
  end

  context "Multiple databases with alternative path" do
    describe "db:create" do
      let(:alternative_path) { "my/alternative/path" }
      let(:custom_path) { File.join tmp_dir, alternative_path }
      let(:dev_db_file) { File.join custom_path, "db/development.sql" }

      before do
        prepare_tmp_project_dir custom_path
        puts system("ls -la spec/tmp/db/")
      end

      it "create sqlite database file in the right path" do
        puts system("cat spec/tmp/db/config.yml")
        puts run "db_path=#{alternative_path} rake db:create"
        File.exists?(dev_db_file).should be_true
      end
    end

    describe "db:migrate" do
      it "execute migrations from the custom path on the right database"
    end
  end
end
