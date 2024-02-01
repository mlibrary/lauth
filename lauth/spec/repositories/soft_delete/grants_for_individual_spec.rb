RSpec.describe "Soft Delete Grants#for Individual", type: :database do
  subject(:grants) { repo.for(username: "lauth-allowed", uri: "/restricted-by-username/") }

  let(:repo) { Lauth::Repositories::GrantRepo.new }
  let(:collection) { Factory[:collection, :restricted_by_username] }
  let(:individual) { Factory[:user, userid: "lauth-allowed"] }
  let(:grant) { Factory[:grant, :for_user, user: individual, collection: collection] }

  before do
    repo
    collection
    individual
    grant
  end

  it "finds the grant" do
    expect(grants.map(&:uniqueIdentifier)).to contain_exactly grant.uniqueIdentifier
  end

  context "when collection is soft deleted" do
    let(:collection) { Factory[:collection, :restricted_by_username, :soft_deleted] }

    it "finds no grants" do
      expect(grants).to be_empty
    end
  end

  context "when collection location is soft deleted" do
    let(:collection) { Factory[:collection, :restricted_by_username_location_soft_deleted] }

    it "finds no grants" do
      expect(grants).to be_empty
    end
  end

  context "when individual is soft deleted" do
    let(:individual) { Factory[:user, :soft_deleted, userid: "lauth-allowed"] }

    it "finds no grants" do
      expect(grants).to be_empty
    end
  end

  context "when grant is soft deleted" do
    let(:grant) { Factory[:grant, :for_user, :soft_deleted, user: individual, collection: collection] }

    it "finds no grants" do
      expect(grants).to be_empty
    end
  end
end
