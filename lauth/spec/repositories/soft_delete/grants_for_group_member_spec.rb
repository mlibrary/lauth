RSpec.describe "Soft Delete Grants#for Group Member", type: :database do
  subject(:grants) { repo.for(username: "lauth-group-member", uri: "/restricted-by-username/") }

  let(:repo) { Lauth::Repositories::GrantRepo.new }
  let(:collection) { Factory[:collection, :restricted_by_username, dlpsClass: "someclass"] }
  let(:group) { Factory[:group] }
  let(:member) { Factory[:user, userid: "lauth-group-member"] }
  let(:membership) { Factory[:group_membership, user: member, group: group] }
  let(:grant) { Factory[:grant, :for_group, group: group, collection: collection] }

  before do
    repo
    collection
    group
    member
    membership
    grant
  end

  it "finds the grant" do
    expect(grants.map(&:uniqueIdentifier)).to contain_exactly grant.uniqueIdentifier
  end

  it "#for_collection_class finds the grant" do
    expect(repo.for_collection_class(
      username: "lauth-group-member",
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

  context "when group is soft deleted" do
    let(:group) { Factory[:group, :soft_deleted] }

    it "finds no grants" do
      expect(grants).to be_empty
    end

    it "#for_collection_class finds no grants" do
      expect(repo.for_collection_class(
        username: "lauth-group-member",
        client_ip: "10.99.3.4",
        collection_class: "someclass"
      )).to be_empty
    end
  end

  context "when member is soft deleted" do
    let(:member) { Factory[:user, :soft_deleted, userid: "lauth-group-member"] }

    it "finds no grants" do
      expect(grants).to be_empty
    end
  end

  context "when membership is soft deleted" do
    let(:membership) { Factory[:group_membership, :soft_deleted, user: member, group: group] }

    it "finds no grants" do
      expect(grants).to be_empty
    end

    it "#for_collection_class finds no grants" do
      expect(repo.for_collection_class(
        username: "lauth-group-member",
        client_ip: "10.99.3.4",
        collection_class: "someclass"
      )).to be_empty
    end
  end

  context "when grant is soft deleted" do
    let(:grant) { Factory[:grant, :for_group, :soft_deleted, group: group, collection: collection] }

    it "finds no grants" do
      expect(grants).to be_empty
    end
  end
end
