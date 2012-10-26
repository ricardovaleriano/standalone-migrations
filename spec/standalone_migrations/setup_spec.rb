describe StandaloneMigrations::Setup do
  let(:alternative_path) { "omgLoL" }
  before do
    StandaloneMigrations.alternative_root_db_path = alternative_path
  end

  describe "#configure_railtie" do
    before { subject.configure_railtie }

    it "define the Rails.application object" do
      Rails.application.should_not be_nil
    end

    it "add an alternative_path to db/migrate" do
      db_migrate_path = Rails.application.paths["db/migrate"][0]
      db_migrate_path.should == alternative_path
    end

    after { subject.restore_originals }
  end

  after do
    StandaloneMigrations.alternative_root_db_path = nil
  end
end
