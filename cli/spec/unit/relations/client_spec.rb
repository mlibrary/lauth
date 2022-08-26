RSpec.describe Lauth::API::ROM::Relations::Clients do
  let(:client) { Factory[:client] }

  describe "#id" do
    let(:client) { Factory[:client, id: 1] }

    it "returns initialized value" do
      expect(client.id).to eq(1)
    end
  end

  describe "#name" do
    let(:client) { Factory[:client, name: "name"] }
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
