RSpec.describe "Soft Delete Grants#for_collection_class", type: :database do
  subject(:grants) { repo.for_collection_class(username: "lauth-allowed", collection_class: "same-class", client_ip: "1.2.3.4") }

  let(:repo) { Lauth::Repositories::GrantRepo.new }
  let(:collection_a) { Factory[:collection, :restricted_by_username, dlpsClass: "same-class"] }
  let(:collection_b) { Factory[:collection, dlpsClass: "same-class"] }
  let(:individual) { Factory[:user, userid: "lauth-allowed"] }
  let(:grant_a) { Factory[:grant, :for_user, user: individual, collection: collection_a] }
  let(:grant_b) { Factory[:grant, :for_user, user: individual, collection: collection_b] }

  before do
    repo
    collection_a
    collection_b
    individual
    grant_a
    grant_b
  end

  it "finds the grants" do
    expect(grants.map(&:uniqueIdentifier)).to contain_exactly grant_a.uniqueIdentifier, grant_b.uniqueIdentifier
  end

  context "when collection_a is soft deleted" do
    let(:collection_a) { Factory[:collection, :restricted_by_username, :soft_deleted, dlpsClass: "same-class"] }

    it "finds only grant_b" do
      expect(grants.map(&:uniqueIdentifier)).to contain_exactly grant_b.uniqueIdentifier
    end
  end

  xcontext "when collection_a location is soft deleted" do
    let(:collection_a) { Factory[:collection, :restricted_by_username_location_soft_deleted, dlpsClass: "same-class"] }

    it "finds only grant_b" do
      expect(grants.map(&:uniqueIdentifier)).to contain_exactly grant_b.uniqueIdentifier
    end
  end

  context "when collection_b is soft deleted" do
    let(:collection_b) { Factory[:collection, :soft_deleted, dlpsClass: "same-class"] }

    it "finds only grant_a" do
      expect(grants.map(&:uniqueIdentifier)).to contain_exactly grant_a.uniqueIdentifier
    end
  end

  xcontext "when collection_b location is soft deleted" do
    let(:collection_b) { Factory[:collection, :location_soft_deleted, dlpsClass: "same-class"] }

    it "finds only grant_a" do
      expect(grants.map(&:uniqueIdentifier)).to contain_exactly grant_a.uniqueIdentifier
    end
  end

  context "when individual is soft deleted" do
    let(:individual) { Factory[:user, :soft_deleted, userid: "lauth-allowed"] }

    it "finds no grants" do
      expect(grants).to be_empty
    end
  end

  context "when grant_a is soft deleted" do
    let(:grant_a) { Factory[:grant, :for_user, :soft_deleted, user: individual, collection: collection_a] }

    it "only finds grant_b" do
      expect(grants.map(&:uniqueIdentifier)).to contain_exactly grant_b.uniqueIdentifier
    end
  end

  context "when grant_b is soft deleted" do
    let(:grant_b) { Factory[:grant, :for_user, :soft_deleted, user: individual, collection: collection_b] }

    it "only finds grant_a" do
      expect(grants.map(&:uniqueIdentifier)).to contain_exactly grant_a.uniqueIdentifier
    end
  end
end
