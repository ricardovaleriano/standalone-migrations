describe StandaloneMigrations::Setup do
  let(:alternative_path) { "omgLoL" }
  before do
    ENV['db_path'] = alternative_path
  end

  describe "#configure_railtie" do
    before { subject.configure_railtie }

    it "define the Rails.application object" do
      Rails.application.should_not be_nil
    end

    it "add an alternative_path to db/migrate" do
      db_migrate_path = Rails.application.paths["db/migrate"].first
      db_migrate_path.should include alternative_path
    end
  end

  after do
    StandaloneMigrations.alternative_root_db_path = nil
    ENV['db_path'] = nil
  end
end
