RSpec.describe Lauth::API::ROM::Mappers::Client do
  let(:clients) { Lauth::API::BDD.rom.relations.clients }
  let(:client) { Factory[:client] }

  before { client }

  it "maps to name" do
    expect(clients.map_with(:clients_mapper).to_a).to eq([client.name])
  end
end
