RSpec.describe Lauth::API::Repositories::Collection do
  let(:repo) { described_class.new(Lauth::API::BDD.rom) }

  it "has no collections" do
    expect(repo.index.count).to eq(0)
  end

  describe "#collection and #collections" do
    let!(:new_collection) { Factory[:collection, uniqueIdentifier: "Identifier2"] }
    let!(:deleted_collection) { Factory[:collection, uniqueIdentifier: "Identifier1", dlpsDeleted: "t"] }

    it "now has only one collection" do
      expect(repo.index.count).to eq(1)
    end

    it "finds the new collection" do
      expect(repo.read("Identifier2").id).to eq("Identifier2")
    end

    it "does NOT find the deleted collection" do
      expect(repo.read("Identifier1")).to be nil
    end

    it "does NOT find an unknown collection" do
      expect(repo.read("Identifier3")).to be nil
    end
  end
end
