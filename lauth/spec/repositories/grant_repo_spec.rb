# require "hanami_helper"

RSpec.describe Lauth::Repositories::GrantRepo, type: :database do
  subject(:repo) { Lauth::Repositories::GrantRepo.new }

  xcontext "with one grant" do
    let!(:grant) { Factory[:grant] }
    it "finds the grant" do
      g = grant_repo.find(grant.uniqueIdentifier)
      expect(grant).to eq g
    end
  end

  context "with a grant for one user to a collection restricted by username" do
    let!(:collection) { Factory[:collection, :restricted_by_username] }
    let!(:grant) { Factory[:grant, collection: collection] }

    it "finds the grant for a resource within the collection" do
      grant = repo.for_uri("/restricted-by-username/").first

      expect(grant.collection.commonName).to match(/Name/)
      expect(grant.collection.locations.first.dlpsServer).to eq "some.host"
      expect(grant.collection.locations.first.dlpsPath).to eq "/restricted-by-username%"
    end

    it "find no grants for a resource not in the collection" do
      grant = repo.for_uri("/something-else/")

      expect(grant).to eq []
    end
  end
  # grant_repo.for_uri("/user/").for_user(username: "lauth-allowed")
end
