RSpec.describe Lauth::API::Repositories::Network do
  let(:repo) { described_class.new(Lauth::API::BDD.rom) }
  let(:created_document) do
    {
      "data" => {
        "id" => 1,
        "type" => "networks",
        "attributes" => {
          "cidr" => created_ip_address.to_string
        }
      }
    }
  end
  let(:created_ip_address) { IPAddress.parse "192.0.0.3/24" }
  let(:created_network) { repo.create(created_document) }
  let(:updated_document) do
    {
      "data" => {
        "id" => 1,
        "type" => "networks",
        "attributes" => {
          "cidr" => updated_ip_address.to_string
        }
      }
    }
  end
  let(:updated_ip_address) { IPAddress.parse "192.0.1.3/24" }
  let(:updated_network) { repo.update(updated_document) }
  let(:invalid_document) do
    {
      "data" => {
        "id" => 1,
        "type" => "networks",
        "attributes" => {
        }
      }
    }
  end

  it "has no networks" do
    expect(repo.index.count).to eq(0)
  end

  describe "index and read" do
    let!(:undeleted_network) { Factory[:network, uniqueIdentifier: 2] }
    let!(:deleted_network) { Factory[:network, uniqueIdentifier: 1, dlpsDeleted: "t"] }

    it "now has only one network" do
      expect(repo.index.count).to eq(1)
    end

    it "finds the undeleted network" do
      expect(repo.read(2).id).to eq(2)
    end

    it "does NOT find the deleted network" do
      expect(repo.read(1)).to be nil
    end

    it "does NOT find an unknown network" do
      expect(repo.read(3)).to be nil
    end
  end

  describe "create, update and delete" do
    it "creates a network" do
      created_network
      expect(repo.read(created_network.id)).to eq(created_network)
    end

    it "updates a network" do
      created_network
      updated_network
      expect(repo.read(created_network.id)).to eq(updated_network)
    end

    it "deletes a network" do
      created_network
      deleted_network = repo.delete(created_network.id)
      expect(deleted_network).to eq(created_network)
      expect(repo.read(created_network.id)).to be nil
    end
  end

  describe "ip network" do
    context "singularity (one node)" do
      let(:created_ip_address) { IPAddress.parse "192.0.0.3/32" }
      let(:updated_ip_address) { IPAddress.parse "192.0.1.3/32" }

      it "cidr is start node address" do
        expect(created_network.cidr).to eq("192.0.0.3/32")
        expect(updated_network.cidr).to eq("192.0.1.3/32")
      end

      it "minimum starts at node address" do
        expect(created_network.minimum).to eq(created_ip_address.to_u32)
        expect(updated_network.minimum).to eq(updated_ip_address.to_u32)
      end

      it "maximum ends at node address" do
        expect(created_network.maximum).to eq(created_ip_address.to_u32)
        expect(updated_network.maximum).to eq(updated_ip_address.to_u32)
      end

      context "include?" do
        before { created_network }

        it "not found" do
          created_network
          expect(repo.include?(updated_ip_address).to_a).to be_empty
        end

        it "found" do
          created_network
          expect(repo.include?(created_ip_address).to_a).to contain_exactly(created_network)
        end
      end
    end

    context "degenerate (two nodes)" do
      let(:created_ip_address) { IPAddress.parse "192.0.0.3/31" }
      let(:updated_ip_address) { IPAddress.parse "192.0.1.3/31" }

      it "cidr is start node address" do
        expect(created_network.cidr).to eq("192.0.0.2/31")
        expect(updated_network.cidr).to eq("192.0.1.2/31")
      end

      it "minimum starts at first node address" do
        expect(created_network.minimum).to eq(created_ip_address.first.to_u32)
        expect(updated_network.minimum).to eq(updated_ip_address.first.to_u32)
      end

      it "maximum ends at last node address" do
        expect(created_network.maximum).to eq(created_ip_address.last.to_u32)
        expect(updated_network.maximum).to eq(updated_ip_address.last.to_u32)
      end

      context "include?" do
        before { created_network }

        it "not found" do
          created_network
          expect(repo.include?(updated_ip_address).to_a).to be_empty
        end

        it "found" do
          created_network
          expect(repo.include?(created_ip_address).to_a).to contain_exactly(created_network)
        end
      end
    end

    context "valid network (network, two or more nodes, broadcast" do
      let(:created_ip_address) { IPAddress.parse "192.0.0.3/30" }
      let(:updated_ip_address) { IPAddress.parse "192.0.1.3/30" }

      it "cidr is network address" do
        expect(created_network.cidr).to eq("192.0.0.0/30")
        expect(updated_network.cidr).to eq("192.0.1.0/30")
      end

      it "minimum starts at network address" do
        expect(created_network.minimum).to eq(created_ip_address.network.to_u32)
        expect(updated_network.minimum).to eq(updated_ip_address.network.to_u32)
      end

      it "maximum ends at broadcast address" do
        expect(created_network.maximum).to eq(created_ip_address.broadcast.to_u32)
        expect(updated_network.maximum).to eq(updated_ip_address.broadcast.to_u32)
      end

      context "include?" do
        before { created_network }

        it "not found" do
          created_network
          expect(repo.include?(updated_ip_address).to_a).to be_empty
        end

        it "found" do
          created_network
          expect(repo.include?(created_ip_address).to_a).to contain_exactly(created_network)
        end
      end
    end
  end

  describe "change failures" do
    it "fails to create on missing cidr attribute" do
      expect(repo.create(invalid_document)).to be nil
    end

    it "fails to update on missing cidr attribute" do
      created_network
      expect(repo.update(invalid_document)).to be nil
    end

    it "fails to update a non-existing network" do
      expect(repo.update(updated_document)).to be nil
    end

    it "fails to delete a non-existing network" do
      expect(repo.delete(1)).to be nil
    end
  end
end
