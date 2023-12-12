# require "hanami_helper"

RSpec.describe Lauth::Repositories::GrantRepo, type: :database do
  subject(:repo) { Lauth::Repositories::GrantRepo.new }

  context "when authorizing locations within a collection using identity-only authentication" do
    context "with an authorized individual" do
      let!(:collection) { Factory[:collection, :restricted_by_username] }
      let!(:user) { Factory[:user, userid: "lauth-allowed"] }
      let!(:grant) { Factory[:grant, :for_user, user: user, collection: collection] }

      it "finds the grant for authorized individual and location within the collection" do
        grants = repo.for_user_and_uri("lauth-allowed", "/restricted-by-username/")

        expect(grants.first.uniqueIdentifier).to eq grant.uniqueIdentifier
      end

      it "finds no grant for unauthorized individual and location within the collection" do
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

    context "with a member of an authorized institution" do
      let!(:collection) { Factory[:collection, :restricted_by_username] }
      let!(:institution) { Factory[:institution] }
      let!(:user) { Factory[:user, userid: "lauth-inst-member"] }
      let!(:membership) { Factory[:institution_membership, user: user, institution: institution] }
      let!(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection] }

      it "finds that member's grant" do
        grant_ids = repo.for_user_and_uri("lauth-inst-member", "/restricted-by-username/")
          .map(&:uniqueIdentifier)

        expect(grant_ids).to contain_exactly(grant.uniqueIdentifier)
      end

      it "finds nothing for a nonmember" do
        grants = repo.for_user_and_uri("lauth-denied", "/restricted-by-username/")

        expect(grants).to be_empty
      end

      it "finds nothing for an empty user" do
        grants = repo.for_user_and_uri("", "/restricted-by-username/")

        expect(grants).to be_empty
      end

      it "finds nothing for a nil user" do
        grants = repo.for_user_and_uri(nil, "/restricted-by-username/")

        expect(grants).to be_empty
      end
    end

    context "with a member of an authorized group" do
      let!(:collection) { Factory[:collection, :restricted_by_username] }
      let!(:user) { Factory[:user, userid: "lauth-group-member"] }
      let!(:group) {
        Factory[:group]
        relations.groups.last
      }
      let!(:membership) { Factory[:group_membership, user: user, group: group] }
      let!(:grant) { Factory[:grant, :for_group, group: group, collection: collection] }

      it "finds that member's grant" do
        grant_ids = repo.for_user_and_uri("lauth-group-member", "/restricted-by-username/")
          .map(&:uniqueIdentifier)

        expect(grant_ids).to contain_exactly(grant.uniqueIdentifier)
      end

      it "finds nothing for a nonmember" do
        grants = repo.for_user_and_uri("lauth-denied", "/restricted-by-username/")

        expect(grants).to be_empty
      end

      it "finds nothing for an empty user" do
        grants = repo.for_user_and_uri("", "/restricted-by-username/")

        expect(grants).to be_empty
      end

      it "finds nothing for a nil user" do
        grants = repo.for_user_and_uri(nil, "/restricted-by-username/")

        expect(grants).to be_empty
      end
    end
  end
end
