describe StandaloneMigrations::Setup do
  let(:alternative_path) { "omgLoL" }
  before do
    StandaloneMigrations.
      stub(:alternative_root_db_path).
      and_return(alternative_path)
  end

  describe "#paths" do
    before { subject.paths }

    it "add an alternative_path to db/migrate" do
      db_migrate_path = Rails.application.paths["db/migrate"][0]
      db_migrate_path.should == alternative_path
    end

    after { subject.restore_originals }
  end

  describe "#configure_railtie" do
    before { subject.configure_railtie }

    it "define the Rails.application object" do
      Rails.application.should_not be_nil
    end

    after { subject.restore_originals }
  end
end
