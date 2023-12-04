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

  context "with a grant for one user to one collection" do
    let!(:collection) { Factory[:collection, :restricted_to_users] }
    let!(:grant) { Factory[:grant, collection: collection] }

    context "for a non-contained resource" do
      it "finds no grants" do
        grant = repo.for_uri("/nonexistent/").one

        expect(grant).to be_nil
      end
    end

    it "finds the grant" do
      # collection = Factory[:collection, :restricted_to_users]
      # Factory[:grant, collection: collection]
      # repo = Lauth::Persistence::Repositories::GrantRepo.new

      grant = repo.for_uri("/user/").one

      expect(grant.collection.commonName).to match(/Name/)
      expect(grant.collection.locations.first.dlpsServer).to eq "some.host"
      expect(grant.collection.locations.first.dlpsPath).to eq "/user%"
    end
  end
  # grant_repo.for_uri("/user/").for_user(username: "lauth-allowed")
end
