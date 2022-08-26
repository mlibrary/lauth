RSpec.describe Lauth::API::ROM::Changesets::Client do
  let(:clients) { Lauth::API::BDD.rom.relations.clients }

  it "is called" do
    expect(clients.command(:client_create).call(name: "Greg")[0].name).to eq("Greg")
  end

  it "creates a client record" do
    clients.command(:client_create).call(name: "Greg")
    expect(clients.count).to eq(1)
  end
end
