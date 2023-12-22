# require "hanami_helper"

RSpec.describe "Soft Delete", type: :database do
  def contains_exactly_grants?(grants1, grants2)
    return false if grants1.count != grants2.count

    grants2.each do |grant|
      return false unless grants1.map(&:uniqueIdentifier).include?(grant.uniqueIdentifier)
    end

    true
  end

  describe "when authorizing locations within a collection using identity-only authentication" do
    subject(:grants) { @grant_repo.for(username: "lauth-allowed", uri: "/restricted-by-username/") }

    before do
      @relations = Hanami.app["persistence.rom"]["relations"]
      @grant_repo = Lauth::Repositories::GrantRepo.new
      @collection = Factory[:collection, :restricted_by_username]
      @location = @collection.locations.first
      @user = Factory[:user, userid: "lauth-allowed"]
      @user_grant = Factory[:grant, :for_user, user: @user, collection: @collection]
      @institution = Factory[:institution]
      @institution_user = Factory[:user, userid: "lauth-inst-member"]
      @institution_membership = Factory[:institution_membership, user: @institution_user, institution: @institution]
      @institution_grant = Factory[:grant, :for_institution, institution: @institution, collection: @collection]
      Factory[:group]
      @group = @relations.groups.last
      @group_user = Factory[:user, userid: "lauth-group-member"]
      @group_membership = Factory[:group_membership, user: @group_user, group: @group]
      @group_grant = Factory[:grant, :for_group, group: @group, collection: @collection]
    end

    it "contains three grants" do
      pp grants.to_a
      expect(contains_exactly_grants?(grants, [@user_grant, @group_grant, @institution_grant])).to be true
    end

    context "when username grant is deleted" do
      it "contains two grants" do
        @relations.grants.where(uniqueIdentifier: @user_grant.uniqueIdentifier).changeset(:update, dlpsDeleted: "t").commit

        expect(contains_exactly_grants?(grants, [@group_grant, @institution_grant])).to be true
      end
    end

    context "when collection is deleted" do
      it "contains no grants" do
        @relations.collections.where(uniqueIdentifier: @collection.uniqueIdentifier).changeset(:update, dlpsDeleted: "t").commit

        expect(grants.first).to eq nil
      end
    end

    context "when location is deleted" do
      it "contains no grants" do
        @relations.locations.where(dlpsPath: "/restricted-by-username%").changeset(:update, dlpsDeleted: "t").commit

        expect(grants.first).to eq nil
      end
    end

    context "when username is deleted" do
      it "contains no grants" do
        @relations.users.where(userid: @user.userid).changeset(:update, dlpsDeleted: "t").commit

        expect(grants.first).to eq nil
      end
    end

    context "when institution is deleted" do
      it "contains two grants" do
        @relations.institutions.where(uniqueIdentifier: @institution.uniqueIdentifier).changeset(:update, dlpsDeleted: "t").commit

        expect(contains_exactly_grants?(grants, [@group_grant, @user_grant])).to be true
      end
    end

    context "when institution membership is deleted" do
      it "contains two grants" do
        @relations.institution_memberships.where(userid: @institution_user.userid).changeset(:update, dlpsDeleted: "t").commit

        expect(contains_exactly_grants?(grants, [@group_grant, @user_grant])).to be true
      end
    end

    context "when institution user is deleted" do
      it "contains three grants" do
        @relations.users.where(userid: @institution_user.userid).changeset(:update, dlpsDeleted: "t").commit

        pp @relations.users.to_a
        pp @relations.grants.to_a
        pp grants.to_a

        expect(contains_exactly_grants?(grants, [@institution_grant, @group_grant, @user_grant])).to be true
      end
    end

    context "when group is deleted" do
      it "contains two grants" do
        @relations.groups.where(uniqueIdentifier: @group.uniqueIdentifier).changeset(:update, dlpsDeleted: "t").commit

        expect(contains_exactly_grants?(grants, [@user_grant, @institution_grant])).to be true
      end
    end

    context "when group membership is deleted" do
      it "contains two grants" do
        @relations.group_memberships.where(userid: @group_user.userid).changeset(:update, dlpsDeleted: "t").commit

        expect(contains_exactly_grants?(grants, [@user_grant, @institution_grant])).to be true
      end
    end

    context "when group user is deleted" do
      it "contains three grants" do
        @relations.users.where(userid: @group_user.userid).changeset(:update, dlpsDeleted: "t").commit

        pp @relations.users.to_a
        pp @relations.grants.to_a
        pp grants.to_a

        expect(contains_exactly_grants?(grants, [@user_grant, @group_grant, @institution_grant])).to be true
      end
    end
  end
end
