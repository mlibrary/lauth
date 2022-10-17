RSpec.describe Lauth::API::Repositories::Network do
  let(:repo) { described_class.new(Lauth::API::BDD.rom) }

  it "has no networks" do
    expect(repo.index.count).to eq(0)
  end

  describe "#network and #networks" do
    let!(:new_network) { Factory[:network, uniqueIdentifier: 2] }
    let!(:deleted_network) { Factory[:network, uniqueIdentifier: 1, dlpsDeleted: "t"] }

    it "now has only one network" do
      expect(repo.index.count).to eq(1)
    end

    it "finds the new network" do
      expect(repo.read(2).id).to eq(2)
    end

    it "does NOT find the deleted network" do
      expect(repo.read(1)).to be nil
    end

    it "does NOT find an unknown network" do
      expect(repo.read(3)).to be nil
    end
  end
end
