# require "hanami_helper"

RSpec.describe "Soft Delete", type: :database do
  subject(:repo) { Lauth::Repositories::GrantRepo.new }

  context "when authorizing locations within a collection using identity-only authentication" do
    context "with an authorized individual" do
      subject(:grants) { repo.for_user_and_uri("lauth-allowed", "/restricted-by-username/") }

      let!(:collection) { Factory[:collection, :restricted_by_username] }
      let!(:user) { Factory[:user, userid: "lauth-allowed"] }
      let!(:grant) { Factory[:grant, :for_user, user: user, collection: collection] }

      context "when collection soft deleted" do
        let!(:collection) { Factory[:collection, :restricted_by_username, dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end

      context "when user soft deleted" do
        let!(:user) { Factory[:user, userid: "lauth-allowed", dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end

      context "when grant soft deleted" do
        let!(:grant) { Factory[:grant, :for_user, user: user, collection: collection, dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end
    end

    context "with a member of an authorized institution" do
      subject(:grants) { repo.for_user_and_uri("lauth-inst-member", "/restricted-by-username/") }

      let!(:collection) { Factory[:collection, :restricted_by_username] }
      let!(:institution) { Factory[:institution] }
      let!(:user) { Factory[:user, userid: "lauth-inst-member"] }
      let!(:membership) { Factory[:institution_membership, user: user, institution: institution] }
      let!(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection] }

      context "when collection soft deleted" do
        let!(:collection) { Factory[:collection, :restricted_by_username, dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end

      context "when institution soft deleted" do
        let!(:institution) { Factory[:institution, dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end

      context "when user soft deleted" do
        let!(:user) { Factory[:user, userid: "lauth-inst-member", dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end

      context "when membership soft deleted" do
        let!(:membership) { Factory[:institution_membership, user: user, institution: institution, dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end

      context "when grant soft deleted" do
        let!(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection, dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end
    end

    context "with a member of an authorized group" do
      subject(:grants) { repo.for_user_and_uri("lauth-group-member", "/restricted-by-username/") }

      let!(:collection) { Factory[:collection, :restricted_by_username] }
      let!(:user) { Factory[:user, userid: "lauth-group-member"] }
      let!(:group) {
        Factory[:group]
        relations.groups.last
      }
      let!(:membership) { Factory[:group_membership, user: user, group: group] }
      let!(:grant) { Factory[:grant, :for_group, group: group, collection: collection] }

      context "when collection soft deleted" do
        let!(:collection) { Factory[:collection, :restricted_by_username, dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end

      context "when user soft deleted" do
        let!(:user) { Factory[:user, userid: "lauth-group-member", dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end

      context "when group soft deleted" do
        let!(:group) {
          Factory[:group, dlpsDeleted: "t"]
          relations.groups.last
        }

        it { expect(grants).to eq [] }
      end

      context "when membership soft deleted" do
        let!(:membership) { Factory[:group_membership, group: group, user: user, dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end

      context "when grant soft deleted" do
        let!(:grant) { Factory[:grant, :for_group, group: group, collection: collection, dlpsDeleted: "t"] }

        it { expect(grants).to eq [] }
      end
    end
  end
end
