RSpec.describe Lauth::API::ROM::Entities::Client do
  let(:client) { Factory.structs[:client] }

  it "creates an in memory client struct" do
    client
    expect(Lauth::API::BDD.rom.relations.clients.count).to eq(0)
  end

  describe "#id" do
    let(:client) { Factory.structs[:client, id: 1] }

    it "returns initialized value" do
      expect(client.id).to eq(1)
    end
  end

  describe "#name" do
    let(:client) { Factory.structs[:client, name: "name"] }
    it "returns initialized value" do
      expect(client.name).to eq("name")
    end
  end

  describe "#resource_object" do
    it "returns a valid json api resource object" do
      expect(client.resource_object).to eq({type: "clients", id: client.id.to_s, attributes: {name: client.name}})
    end
  end

  describe "#resource_identifier_object" do
    it "returns a valid json api resource identifier object" do
      expect(client.resource_identifier_object).to eq({type: "clients", id: client.id.to_s})
    end
  end
end
