RSpec.describe Lauth::API::Repositories::User do
  let(:repo) { described_class.new(Lauth::API::BDD.rom) }

  context "seeded root user" do
    it "has only one user" do
      expect(repo.index.count).to eq(1)
    end

    it "has a root user" do
      expect(repo.index.one.id).to eq("root")
    end

    it "finds the root user by id" do
      expect(repo.read("root").id).to eq("root")
    end

    it "does NOT find a non-root user by id" do
      expect(repo.read("user")).to be nil
    end
  end

  describe "#user and #users" do
    let!(:new_user) { Factory[:user, userid: "new_user"] }
    let!(:deleted_user) { Factory[:user, userid: "deleted_user", dlpsDeleted: "t"] }

    it "now has only two users" do
      expect(repo.index.count).to eq(2)
    end

    it "finds the new user" do
      expect(repo.read("new_user").id).to eq("new_user")
    end

    it "does NOT find the deleted user" do
      expect(repo.read("deleted_user")).to be nil
    end

    it "does NOT find an unknown user" do
      expect(repo.read("unknown_user")).to be nil
    end
  end
end
