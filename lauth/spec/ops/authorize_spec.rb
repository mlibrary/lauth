RSpec.describe Lauth::Ops::Authorize do
  let(:grant_repo) { instance_double("Lauth::Repositories::GrantRepo") }
  let(:collection_repo) {instance_double("Lauth::Repositories::CollectionRepo")}
  let(:request) do
    Lauth::Access::Request.new(
      user: "cool_dude",
      uri: "/some/uri/",
      client_ip: "10.11.22.33"
    )
  end
  subject(:op) do
    Lauth::Ops::Authorize.new(grant_repo: grant_repo, collection_repo: collection_repo)
  end

  # TODO: Consider refactoring to require less mocking

  describe "normal mode" do
    before(:each) do
      allow(collection_repo).to receive(:find_by_uri)
        .with("/some/uri/")
        .and_return(double(dlpsAuthzType: "n"))
    end

    it "allows a request with a grant" do
      allow(grant_repo).to receive(:for).with(
        username: "cool_dude",
        uri: "/some/uri/",
        client_ip: "10.11.22.33"
      ).and_return([:somegrant])

      expect(op.call(request: request))
        .to eq Lauth::Access::Result.new(determination: "allowed")
    end

    it "denies a request without any grants" do
      allow(grant_repo).to receive(:for).with(
        username: "cool_dude",
        uri: "/some/uri/",
        client_ip: "10.11.22.33"
      ).and_return([])

      expect(op.call(request: request))
        .to eq Lauth::Access::Result.new(determination: "denied")
    end
  end

  describe "delegated mode" do
    before(:each) do
      allow(collection_repo).to receive(:find_by_uri).with("/some/uri/")
        .and_return(double(dlpsAuthzType: "d", dlpsClass: "fooclass"))
      allow(collection_repo).to receive(:public_in_class).with("fooclass")
        .and_return([])
      allow(grant_repo).to receive(:for_collection_class).with(
        username: "cool_dude",
        client_ip: "10.11.22.33",
        collection_class: "fooclass"
      ).and_return([])
    end

    it "allows the request" do
      expect(op.call(request: request)).to eq Lauth::Access::Result.new(
        determination: "allowed",
        public_collections: [],
        authorized_collections: []
      )
    end

  end

end
