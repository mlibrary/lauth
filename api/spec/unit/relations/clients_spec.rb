RSpec.describe Lauth::API::ROM::Relations::Clients do
  let(:clients) { Lauth::API::BDD.rom.relations.clients }

  it "empty" do
    expect(clients.count).to eq(0)
  end

  context "client" do
    before { Factory[:client] }

    it "has one client" do
      expect(clients.count).to eq(1)
    end
  end

  describe "listing" do
    before { Factory[:client] }

    it "has one listing" do
      expect(clients.listing.count).to eq(1)
    end
  end
end
