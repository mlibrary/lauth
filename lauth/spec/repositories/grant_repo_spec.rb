# require "hanami_helper"

RSpec.describe Lauth::Repositories::GrantRepo, type: :database do
  subject(:repo) { Lauth::Repositories::GrantRepo.new }

  def cidr_range(x)
    (32 - Math.log2((x.to_range.last.to_i - x.to_range.first.to_i) + 1)).to_i
  end

  def build_network(cidr, institution)
    ip_range = IPAddr.new(cidr)
    Factory[
      :network,
      :for_institution,
      institution: institution,
      dlpsCIDRAddress: [ip_range, cidr_range(ip_range).to_s].join("/"),
      dlpsAddressStart: ip_range.to_range.first.to_i,
      dlpsAddressEnd: ip_range.to_range.last.to_i,
    ]
  end

  context "when authorizing locations within a collection using only client_ip" do
    context "within the network" do
      let!(:institution) { Factory[:institution] }
      let!(:network) { build_network("10.1.16.0/24", institution) }
      let!(:collection) { Factory[:collection, :restricted_by_client_ip] }
      let!(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection] }
      it "finds the network grant" do
        repo.for(username: "", uri: "/restricted-by-client-ip/", client_ip: "10.1.16.1")
      end
    end
  end

  context "when authorizing locations within a collection using identity-only authentication" do
    context "with an authorized individual" do
      let!(:collection) { Factory[:collection, :restricted_by_username] }
      let!(:user) { Factory[:user, userid: "lauth-allowed"] }
      let!(:grant) { Factory[:grant, :for_user, user: user, collection: collection] }

      it "finds the grant for authorized individual and location within the collection" do
        grants = repo.for(username: "lauth-allowed", uri: "/restricted-by-username/")

        expect(grants.first.uniqueIdentifier).to eq grant.uniqueIdentifier
      end

      it "finds no grant for unauthorized individual and location within the collection" do
        grants = repo.for(username: "lauth-denied", uri: "/restricted-by-username/")

        expect(grants).to eq []
      end

      # TODO: extract this
      describe "grant association loading" do
        subject(:found_grant) { repo.for(username: "lauth-allowed", uri: "/restricted-by-username/").first }

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
        grant_ids = repo.for(username: "lauth-inst-member", uri: "/restricted-by-username/")
          .map(&:uniqueIdentifier)

        expect(grant_ids).to contain_exactly(grant.uniqueIdentifier)
      end

      it "finds nothing for a nonmember" do
        grants = repo.for(username: "lauth-denied", uri: "/restricted-by-username/")

        expect(grants).to be_empty
      end

      it "finds nothing for an empty user" do
        grants = repo.for(username: "", uri: "/restricted-by-username/")

        expect(grants).to be_empty
      end

      it "finds nothing for a nil user" do
        grants = repo.for(username: nil, uri: "/restricted-by-username/")

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
        grant_ids = repo.for(username: "lauth-group-member", uri: "/restricted-by-username/")
          .map(&:uniqueIdentifier)

        expect(grant_ids).to contain_exactly(grant.uniqueIdentifier)
      end

      it "finds nothing for a nonmember" do
        grants = repo.for(username: "lauth-denied", uri: "/restricted-by-username/")

        expect(grants).to be_empty
      end

      it "finds nothing for an empty user" do
        grants = repo.for(username: "", uri: "/restricted-by-username/")

        expect(grants).to be_empty
      end

      it "finds nothing for a nil user" do
        grants = repo.for(username: nil, uri: "/restricted-by-username/")

        expect(grants).to be_empty
      end
    end
  end
end
