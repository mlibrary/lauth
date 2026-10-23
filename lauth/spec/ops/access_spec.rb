RSpec.describe Lauth::Ops::Access do
  let(:grant_repo) { instance_double("Lauth::Repositories::GrantRepo") }
  let(:collection_repo) { instance_double("Lauth::Repositories::CollectionRepo") }
  let(:group_membership_repo) { instance_double("Lauth::Repositories::GroupMembershipRepo") }
  let(:collection) { double(uniqueIdentifier: "example", dlpsAuthzType: "n") }
  subject(:op) do
    described_class.new(
      grant_repo: grant_repo,
      collection_repo: collection_repo,
      group_membership_repo: group_membership_repo
    )
  end

  it "checks a collection by user without requiring an IP" do
    allow(grant_repo).to receive(:for).with(
      username: "alice", collection: collection, client_ip: nil
    ).and_return([:grant])

    expect(op.call(collection: collection, user: "alice")).to eq(
      Lauth::Access::Result.new(determination: "allowed")
    )
  end

  it "rejects a non-IPv4 IP" do
    expect {
      op.call(collection: collection, user: "alice", client_ip: "not-an-ip")
    }.to raise_error(ArgumentError, "ip must be an IPv4 address")
  end

  it "allows non-members to inspect management collections without authorization" do
    managed = double(uniqueIdentifier: "legacy", dlpsAuthzType: "m", manager: 7)
    allow(group_membership_repo).to receive(:member?).with("alice", 7).and_return(false)

    expect(op.call(collection: managed, user: "alice")).to eq(
      Lauth::Access::Result.new(
        determination: "allowed", authorized_collections: [], public_collections: []
      )
    )
  end

  it "returns managed collections for a management group member" do
    managed = double(uniqueIdentifier: "legacy", dlpsAuthzType: "m", manager: 7)
    allow(group_membership_repo).to receive(:member?).with("alice", 7).and_return(true)
    allow(collection_repo).to receive(:managed_by).with(7).and_return(
      [double(uniqueIdentifier: "legacy"), double(uniqueIdentifier: "legacy-dev")]
    )

    expect(op.call(collection: managed, user: "alice")).to eq(
      Lauth::Access::Result.new(
        determination: "allowed",
        authorized_collections: ["legacy", "legacy-dev"],
        public_collections: []
      )
    )
  end

  it "returns All for a root management group member" do
    managed = double(uniqueIdentifier: "legacy", dlpsAuthzType: "m", manager: 0)
    allow(group_membership_repo).to receive(:member?).with("alice", 0).and_return(true)

    expect(op.call(collection: managed, user: "alice")).to eq(
      Lauth::Access::Result.new(
        determination: "allowed", authorized_collections: ["All"], public_collections: []
      )
    )
  end
end
