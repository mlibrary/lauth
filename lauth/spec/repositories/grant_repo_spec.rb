# require "hanami_helper"

RSpec.describe Lauth::Repositories::GrantRepo, type: :database do
  subject(:repo) { Lauth::Repositories::GrantRepo.new }

  context "with a grant for one user to a collection restricted by username" do
    let!(:collection) { Factory[:collection, :restricted_by_username] }
    let!(:user) { Factory[:user, userid: "lauth-allowed"] }
    let!(:grant) { Factory[:grant, user: user, collection: collection] }

    # describe #for_uri
    it "finds the grant for a resource within the collection" do
      grant = repo.for_uri("/restricted-by-username/").first

      expect(grant.collection.commonName).to match(/Name/)
      expect(grant.collection.locations.first.dlpsServer).to eq "some.host"
      expect(grant.collection.locations.first.dlpsPath).to eq "/restricted-by-username%"
    end

    it "finds no grants for a resource not in the collection" do
      grants = repo.for_uri("/something-else/")

      expect(grants).to eq []
    end

    # describe #for_user_and_uri
    it "finds the grant for user and location within the collection" do
      grants = repo.for_user_and_uri("lauth-allowed", "/restricted-by-username/")

      expect(grants.first.uniqueIdentifier).to eq grant.uniqueIdentifier
    end

    it "finds no grant for unauthorized user and location within the collection" do
      grants = repo.for_user_and_uri("lauth-denied", "/restricted-by-username/")

      expect(grants).to eq []
    end

    describe "grant association loading" do
      subject(:found_grant) { repo.for_user_and_uri("lauth-allowed", "/restricted-by-username/").first }

      it "loads user" do
        expect(found_grant.user.userid).to eq grant.user.userid
      end

      it "loads collection" do
        expect(found_grant.collection.uniqueIdentifier).to eq "lauth-by-username"
      end

      it "loads location" do
        expect(found_grant.collection.locations.first.dlpsPath).to eq "/restricted-by-username%"
      end
    end
  end
end
