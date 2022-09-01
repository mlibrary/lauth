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

  describe "persistence" do
    it "creates a persistent client record" do
      client_repo = Lauth::API::ROM::Repositories::Client.new(LAUTH_API_ROM)
      client
      expect(client_repo.clients.count).to eq(1)
    end
  end
end
