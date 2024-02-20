RSpec.describe "Soft Delete Grants#for Client IP", type: :database do
  subject(:grants) { repo.for(username: "", collection: collection, client_ip: client_ip) }

  let(:repo) { Lauth::Repositories::GrantRepo.new }
  let(:collection) { Factory[:collection, :restricted_by_client_ip] }
  let(:institution) { Factory[:institution] }
  let(:grant) { Factory[:grant, :for_institution, institution: institution, collection: collection] }

  before do
    repo
    collection
    institution
    grant
  end

  describe "(allow,deny) given a denied enclave within an allowed network" do
    let(:client_ip) { "10.1.6.3" }
    let(:deny_deleted) { "f" }

    before do
      create_network("allow", "10.1.6.0/24")
      create_network("deny", "10.1.6.2/31", deny_deleted)
    end

    it "finds no grants" do
      expect(grants).to be_empty
    end

    context "when deny network is soft deleted" do
      let(:deny_deleted) { "t" }

      it "finds the grant" do
        expect(grants.map(&:uniqueIdentifier)).to contain_exactly(grant.uniqueIdentifier)
      end

      context "when collection is soft deleted" do
        let(:collection) { Factory[:collection, :restricted_by_client_ip, :soft_deleted] }

        it "finds no grants" do
          expect(grants).to be_empty
        end
      end

      context "when institution is soft deleted" do
        let(:institution) { Factory[:institution, :soft_deleted] }

        it "finds no grants" do
          expect(grants).to be_empty
        end
      end

      context "when grant is soft deleted" do
        let(:grant) { Factory[:grant, :for_institution, :soft_deleted, institution: institution, collection: collection] }

        it "finds no grants" do
          expect(grants).to be_empty
        end
      end
    end
  end

  describe "(deny,allow) given an allowed enclave within a denied network" do
    let(:client_ip) { "10.1.7.14" }
    let(:allowed_deleted) { "f" }

    before do
      create_network("deny", "10.1.7.0/24")
      create_network("allow", "10.1.7.8/29", allowed_deleted)
    end

    it "finds the grant" do
      expect(grants.map(&:uniqueIdentifier)).to contain_exactly(grant.uniqueIdentifier)
    end

    context "when allowed network is soft deleted" do
      let(:allowed_deleted) { "t" }

      it "finds no grants" do
        expect(grants).to be_empty
      end
    end

    context "when collection is soft deleted" do
      let(:collection) { Factory[:collection, :restricted_by_client_ip, :soft_deleted] }

      it "finds no grants" do
        expect(grants).to be_empty
      end
    end

    context "when institution is soft deleted" do
      let(:institution) { Factory[:institution, :soft_deleted] }

      it "finds no grants" do
        expect(grants).to be_empty
      end
    end

    context "when grant is soft deleted" do
      let(:grant) { Factory[:grant, :for_institution, :soft_deleted, institution: institution, collection: collection] }

      it "finds no grants" do
        expect(grants).to be_empty
      end
    end
  end

  private

  # Convenience for building networks.
  # Requires 'institution' be set in a let block.
  # @param access [String] Either 'allow' or 'deny'
  # @param cidr [String] A IPv4 CIDR range.
  def create_network(access, cidr, deleted = "f")
    ip_range = IPAddr.new(cidr)
    Factory[
      :network, :for_institution, institution: institution,
      dlpsAccessSwitch: access,
      dlpsCIDRAddress: cidr,
      dlpsAddressStart: ip_range.to_range.first.to_i,
      dlpsAddressEnd: ip_range.to_range.last.to_i,
      dlpsDeleted: deleted
    ]
  end
end
