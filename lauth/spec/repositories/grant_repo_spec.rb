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
    let!(:user) { Factory[:user, userid: "lauth-allowed"] }
    let!(:grant) { Factory[:grant, user: user, collection: collection] }

    it "finds the grant for a resource within the collection" do
      grant = repo.for_uri("/restricted-by-username/").first

      expect(grant.collection.commonName).to match(/Name/)
      expect(grant.collection.locations.first.dlpsServer).to eq "some.host"
      expect(grant.collection.locations.first.dlpsPath).to eq "/restricted-by-username%"
    end

    it "finds the grant for user and location within the collection" do
      my_grant = repo.for_user_and_uri("lauth-allowed", "/restricted-by-username/").first

      expect(grant.uniqueIdentifier).to eq my_grant.uniqueIdentifier
    end

    it "finds no grant for unauthorized user and location within the collection" do
      my_grant = repo.for_user_and_uri("lauth-denied", "/restricted-by-username/")

      expect(my_grant).to eq []
    end

    it "finds no grants for a resource not in the collection" do
      grant = repo.for_uri("/something-else/")

      expect(grant).to eq []
    end

    describe "grant association loading" do
      it "loads user" do
        my_grant = repo.for_user_and_uri("lauth-allowed", "/restricted-by-username/").first

        expect(grant.user.userid).to eq my_grant.user.userid
      end

      it "loads collection" do
        my_grant = repo.for_user_and_uri("lauth-allowed", "/restricted-by-username/").first

        expect(my_grant.collection.uniqueIdentifier).to eq "lauth-by-username"
      end

      it "loads location" do
        my_grant = repo.for_user_and_uri("lauth-allowed", "/restricted-by-username/").first

        expect(my_grant.collection.locations.first.dlpsPath).to eq "/restricted-by-username%"
      end
    end
  end
  # grant_repo.for_uri("/user/").for_user(username: "lauth-allowed")
end
