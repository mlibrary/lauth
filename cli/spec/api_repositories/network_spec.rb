RSpec.describe Lauth::API::Repositories::Network do
  let(:repo) { described_class.new(LAUTH_API_ROM) }
  let(:network) { repo.read(1) }

  it "has two networks after calling the factory twice but factory returns nil networks" do
    network_1 = Factory[:network, uniqueIdentifier: 1]
    network_2 = Factory[:network, uniqueIdentifier: 2]
    expect(repo.index.count).to eq(2)
    expect(repo.index.to_a.map(&:id)).to contain_exactly(1, 2)
    expect(network_1).to be nil
    expect(network_2).to be nil
    expect(repo.read(1).id).to eq(1)
    expect(repo.read(2).id).to eq(2)
  end

  context "network" do
    before { Factory[:network, uniqueIdentifier: 1, dlpsCIDRAddress: "128.32.0.0/16"] }

    describe "#id" do
      it "returns initialized value" do
        expect(network.id).to eq(1)
      end
    end

    describe "#cidr" do
      it "returns initialized value" do
        expect(network.cidr).to eq("128.32.0.0/16")
      end
    end

    describe "#resource_object" do
      it "returns a valid json api resource object" do
        expect(network.resource_object).to eq({type: "networks", id: network.id, attributes: {access: network.access, cidr: network.cidr}})
      end
    end

    describe "#resource_identifier_object" do
      it "returns a valid json api resource identifier object" do
        expect(network.resource_identifier_object).to eq({type: "networks", id: network.id})
      end
    end
  end
end
