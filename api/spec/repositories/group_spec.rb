RSpec.describe Lauth::API::Repositories::Group do
  let(:repo) { described_class.new(Lauth::API::BDD.rom) }

  context "seeded root user group" do
    it "has only one user group" do
      expect(repo.index.count).to eq(1)
    end

    it "has a root user group" do
      expect(repo.index.one.id).to eq(0)
    end

    it "finds the root user group by id" do
      expect(repo.read(0).id).to eq(0)
    end

    it "does NOT find a non-root user group by id" do
      expect(repo.read(1)).to be nil
    end
  end

  describe "#group and #groups" do
    let!(:new_group) { Factory[:group, uniqueIdentifier: 2] }
    let!(:deleted_group) { Factory[:group, uniqueIdentifier: 1, dlpsDeleted: "t"] }

    it "now has only two user groups" do
      expect(repo.index.count).to eq(2)
    end

    it "finds the new user group" do
      expect(repo.read(2).id).to eq(2)
    end

    it "does NOT find the deleted user group" do
      expect(repo.read(1)).to be nil
    end

    it "does NOT find an unknown user group" do
      expect(repo.read(3)).to be nil
    end
  end
end
