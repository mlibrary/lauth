RSpec.describe Lauth::Repositories::GrantRepo, type: :database do
  subject(:repo) { Lauth::Repositories::GrantRepo.new }

  describe "#for" do
    context "when authorizing locations within a collection using only client_ip" do
      let!(:institution) { Factory[:institution] }
      let!(:collection) { Factory[:collection, :restricted_by_client_ip] }
      let!(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection] }
      context "(allow,deny) given a denied enclave within an allowed network" do
        let!(:network) { create_network("allow", "10.1.6.0/24") }
        let!(:enclave) { create_network("deny", "10.1.6.2/31") }
        it "finds no grant for a client_ip within the denied enclave" do
          grants = repo.for(username: "", uri: "/restricted-by-client-ip/", client_ip: "10.1.6.3")

          expect(grants).to eq []
        end
      end
      context "(deny,allow) given an allowed enclave within a denied network" do
        let!(:network) { create_network("deny", "10.1.7.0/24") }
        let!(:enclave) { create_network("allow", "10.1.7.8/29") }
        it "finds the grant for a client_ip within the allowed enclave" do
          grants = repo.for(username: "", uri: "/restricted-by-client-ip/", client_ip: "10.1.7.14")

          expect(grants.first.uniqueIdentifier).to eq grant.uniqueIdentifier
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

  private

  # Convenience for building networks.
  # Requires 'institution' be set in a let block.
  # @param access [String] Either 'allow' or 'deny'
  # @param cidr [String] A IPv4 CIDR range.
  def create_network(access, cidr)
    ip_range = IPAddr.new(cidr)
    Factory[
      :network, :for_institution, institution: institution,
      dlpsAccessSwitch: access,
      dlpsCIDRAddress: cidr,
      dlpsAddressStart: ip_range.to_range.first.to_i,
      dlpsAddressEnd: ip_range.to_range.last.to_i,
    ]
  end

end
