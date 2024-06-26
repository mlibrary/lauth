RSpec.describe Lauth::Repositories::GrantRepo, type: :database do
  subject(:repo) { Lauth::Repositories::GrantRepo.new }

  describe "#for_collection_class" do
    let!(:user) { Factory[:user, userid: "lauth-allowed"] }
    let!(:collection_a) { Factory[:collection, :restricted_by_username, dlpsClass: "same-class"] }
    let!(:collection_b) { Factory[:collection, dlpsClass: "same-class"] }
    let!(:grant_a) { Factory[:grant, :for_user, user: user, collection: collection_a] }
    let!(:grant_b) { Factory[:grant, :for_user, user: user, collection: collection_b] }
    it "finds grants for other collections with the same dlpsClass" do
      grants = repo.for_collection_class(
        username: "lauth-allowed", collection_class: "same-class", client_ip: "1.2.3.4"
      )

      expect(grants.map(&:uniqueIdentifier))
        .to contain_exactly grant_a.uniqueIdentifier, grant_b.uniqueIdentifier
    end
  end

  describe "#for" do
    context "when authorizing locations within a collection using only client_ip" do
      let!(:institution) { Factory[:institution] }
      let!(:collection) { Factory[:collection, :restricted_by_client_ip] }
      let!(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection] }
      context "(allow,deny) given a denied enclave within an allowed network" do
        let!(:network) { create_network("allow", "10.1.6.0/24") }
        let!(:enclave) { create_network("deny", "10.1.6.2/31") }
        it "finds no grant for a client_ip within the denied enclave" do
          grants = repo.for(username: "", collection: collection, client_ip: "10.1.6.3")

          expect(grants).to eq []
        end
      end
      context "(deny,allow) given an allowed enclave within a denied network" do
        let!(:network) { create_network("deny", "10.1.7.0/24") }
        let!(:enclave) { create_network("allow", "10.1.7.8/29") }
        it "finds the grant for a client_ip within the allowed enclave" do
          grants = repo.for(username: "", collection: collection, client_ip: "10.1.7.14")

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
          grants = repo.for(username: "lauth-allowed", collection: collection)

          expect(grants.first.uniqueIdentifier).to eq grant.uniqueIdentifier
        end

        it "finds no grant for unauthorized individual and location within the collection" do
          grants = repo.for(username: "lauth-denied", collection: collection)

          expect(grants).to eq []
        end
      end

      context "with a member of an authorized institution" do
        let!(:collection) { Factory[:collection, :restricted_by_username] }
        let!(:institution) { Factory[:institution] }
        let!(:user) { Factory[:user, userid: "lauth-inst-member"] }
        let!(:membership) { Factory[:institution_membership, user: user, institution: institution] }
        let!(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection] }

        it "finds that member's grant" do
          grant_ids = repo.for(username: "lauth-inst-member", collection: collection)
            .map(&:uniqueIdentifier)

          expect(grant_ids).to contain_exactly(grant.uniqueIdentifier)
        end

        it "finds nothing for a nonmember" do
          grants = repo.for(username: "lauth-denied", collection: collection)

          expect(grants).to be_empty
        end

        it "finds nothing for an empty user" do
          grants = repo.for(username: "", collection: collection)

          expect(grants).to be_empty
        end

        it "finds nothing for a nil user" do
          grants = repo.for(username: nil, collection: collection)

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
          grant_ids = repo.for(username: "lauth-group-member", collection: collection)
            .map(&:uniqueIdentifier)

          expect(grant_ids).to contain_exactly(grant.uniqueIdentifier)
        end

        it "finds nothing for a nonmember" do
          grants = repo.for(username: "lauth-denied", collection: collection)

          expect(grants).to be_empty
        end

        it "finds nothing for an empty user" do
          grants = repo.for(username: "", collection: collection)

          expect(grants).to be_empty
        end

        it "finds nothing for a nil user" do
          grants = repo.for(username: nil, collection: collection)

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
