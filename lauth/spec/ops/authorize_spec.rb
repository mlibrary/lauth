RSpec.describe Lauth::Ops::Authorize do
  let(:collection_repo) { instance_double("Lauth::Repositories::CollectionRepo") }
  let(:access) { instance_double("Lauth::Ops::Access") }
  let(:request) do
    Lauth::Access::Request.new(
      user: "cool_dude",
      uri: "/some/uri/",
      client_ip: "10.11.22.33"
    )
  end
  subject(:op) do
    Lauth::Ops::Authorize.new(
      collection_repo: collection_repo,
      access: access,
      request: request
    )
  end

  describe "normal mode" do
    before(:each) do
      allow(collection_repo).to receive(:find_by_uri)
        .with("/some/uri/")
        .and_return(double(dlpsAuthzType: "n"))
    end

    it "allows a request with a grant" do
      allow(access).to receive(:call).with(
        collection: anything, user: "cool_dude", client_ip: "10.11.22.33"
      ).and_return(Lauth::Access::Result.new(determination: "allowed"))

      expect(op.call).to eq Lauth::Access::Result.new(determination: "allowed")
    end

    it "denies a request without any grants" do
      allow(access).to receive(:call).with(
        collection: anything, user: "cool_dude", client_ip: "10.11.22.33"
      ).and_return(Lauth::Access::Result.new(determination: "denied"))

      expect(op.call).to eq Lauth::Access::Result.new(determination: "denied")
    end
  end

  describe "delegated mode" do
    before(:each) do
      allow(collection_repo).to receive(:find_by_uri).with("/some/uri/")
        .and_return(double(dlpsAuthzType: "d", dlpsClass: "fooclass"))
      allow(access).to receive(:call).with(
        collection: anything, user: "cool_dude", client_ip: "10.11.22.33"
      ).and_return(Lauth::Access::Result.new(
        determination: "allowed", public_collections: [], authorized_collections: []
      ))
    end

    it "allows the request" do
      expect(op.call).to eq Lauth::Access::Result.new(
        determination: "allowed",
        public_collections: [],
        authorized_collections: []
      )
    end
  end
end
