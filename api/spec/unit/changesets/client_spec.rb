RSpec.describe Lauth::API::ROM::Changesets::Client do
  let(:clients) { Lauth::API::BDD.rom.relations.clients }

  xit "is called" do
    clients.command(:client_create).call(name: "Greg")
    expect(clients.changeset(:client_upsert).call(name: "Kostin")[0].name).to eq("Kostin")
  end

  xit "creates a client record" do
    clients.command(:client_create).call(name: "Greg")
    clients.changeset(:client_upsert).call(name: "Kostin")
    expect(clients.count).to eq(1)
  end
end
