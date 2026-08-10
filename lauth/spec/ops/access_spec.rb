RSpec.describe Lauth::Ops::Access do
  let(:grant_repo) { instance_double("Lauth::Repositories::GrantRepo") }
  let(:collection_repo) { instance_double("Lauth::Repositories::CollectionRepo") }
  let(:collection) { double(uniqueIdentifier: "example", dlpsAuthzType: "n") }
  subject(:op) do
    described_class.new(grant_repo: grant_repo, collection_repo: collection_repo)
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
end
