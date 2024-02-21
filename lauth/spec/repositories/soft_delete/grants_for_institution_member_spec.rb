RSpec.describe "Soft Delete Grants#for Institution Member", type: :database do
  subject(:grants) { repo.for(username: "lauth-inst-member", uri: "/restricted-by-username/") }

  let(:repo) { Lauth::Repositories::GrantRepo.new }
  let(:collection) { Factory[:collection, :restricted_by_username, dlpsClass: "someclass"] }
  let(:institution) { Factory[:institution] }
  let(:member) { Factory[:user, userid: "lauth-inst-member"] }
  let(:membership) { Factory[:institution_membership, user: member, institution: institution] }
  let(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection] }

  before do
    repo
    collection
    institution
    member
    membership
    grant
  end

  it "finds the grant" do
    expect(grants.map(&:uniqueIdentifier)).to contain_exactly(grant.uniqueIdentifier)
  end

  it "#for_collection_class finds the grant" do
    expect(repo.for_collection_class(
      username: "lauth-inst-member",
      client_ip: "10.99.3.4",
      collection_class: "someclass"
    ).map(&:uniqueIdentifier)).to contain_exactly grant.uniqueIdentifier
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

  context "when institution is soft deleted" do
    let(:institution) { Factory[:institution, :soft_deleted] }

    it "finds no grants" do
      expect(grants).to be_empty
    end

    it "#for_collection_class finds no grants" do
      expect(repo.for_collection_class(
        username: "lauth-inst-member",
        client_ip: "10.99.3.4",
        collection_class: "someclass"
      )).to be_empty
    end
  end

  context "when member is soft deleted" do
    let(:member) { Factory[:user, :soft_deleted, userid: "lauth-inst-member"] }

    it "finds no grants" do
      expect(grants).to be_empty
    end
  end

  context "when membership is soft deleted" do
    let(:membership) { Factory[:institution_membership, :soft_deleted, user: member, institution: institution] }

    it "finds no grants" do
      expect(grants).to be_empty
    end

    it "#for_collection_class finds no grants" do
      expect(repo.for_collection_class(
        username: "lauth-inst-member",
        client_ip: "10.2.3.4",
        collection_class: "someclass"
      )).to be_empty
    end
  end

  context "when grant is soft deleted" do
    let(:grant) { Factory[:grant, :for_institution, :soft_deleted, institution: institution, collection: collection] }

    it "finds no grants" do
      expect(grants).to be_empty
    end
  end
end
