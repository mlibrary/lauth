RSpec.describe Lauth::API::Repositories::Client do
  let(:repo) { described_class.new(LAUTH_API_ROM) }
  let(:client) { repo.read(1) }

  it "has two clients after calling the factory twice and factory returns clients" do
    client_1 = Factory[:client, id: 1]
    client_2 = Factory[:client, id: 2]
    expect(repo.clients.count).to eq(2)
    expect(repo.clients.to_a.map(&:id)).to contain_exactly(1, 2)
    expect(client_1.id).to eq(1)
    expect(client_2.id).to eq(2)
    expect(repo.read(1).id).to eq(1)
    expect(repo.read(2).id).to eq(2)
  end

  context "client" do
    before { Factory[:client, id: 1, name: "Name"] }

    describe "#id" do
      it "returns initialized value" do
        expect(client.id).to eq(1)
      end
    end

    describe "#name" do
      it "returns initialized value" do
        expect(client.name).to eq("Name")
      end
    end

    describe "#resource_object" do
      it "returns a valid json api resource object" do
        expect(client.resource_object).to eq({type: "clients", id: client.id, attributes: {name: client.name}})
      end
    end

    describe "#resource_identifier_object" do
      it "returns a valid json api resource identifier object" do
        expect(client.resource_identifier_object).to eq({type: "clients", id: client.id})
      end
    end
  end
end
