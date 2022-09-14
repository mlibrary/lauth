RSpec.describe Lauth::API::Repositories::Client do
  let(:repo) { described_class.new(Lauth::API::BDD.rom) }

  it "has no clients" do
    expect(repo.clients.count).to eq(0)
  end

  describe "#client and #clients" do
    let!(:client) { Factory[:client, id: 2] }

    it "contains one client" do
      expect(repo.clients.count).to eq(1)
    end

    it "finds the new client" do
      expect(repo.read(2).id).to eq(2)
    end

    it "does NOT find an unknown client" do
      expect(repo.read(1)).to be nil
    end
  end
end
