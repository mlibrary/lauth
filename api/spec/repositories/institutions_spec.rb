RSpec.describe Lauth::API::Repositories::Institution do
  let(:repo) { described_class.new(Lauth::API::BDD.rom) }

  it "has no institutions" do
    expect(repo.institutions.count).to eq(0)
  end

  describe "#institution and #institutions" do
    let!(:new_institution) { Factory[:institution, uniqueIdentifier: 2] }
    let!(:deleted_institution) { Factory[:institution, uniqueIdentifier: 1, dlpsDeleted: "t"] }

    it "now has only one institution" do
      expect(repo.index.count).to eq(1)
    end

    it "finds the new institution" do
      expect(repo.read(2).id).to eq(2)
    end

    it "does NOT find the deleted institution" do
      expect(repo.read(1)).to be nil
    end

    it "does NOT find an unknown institution" do
      expect(repo.read(3)).to be nil
    end
  end
end
