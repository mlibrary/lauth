RSpec.describe "Soft Delete Collections#find_by_uri", type: :database do
  subject(:repo) { Lauth::Repositories::CollectionRepo.new }

  describe "#find_by_uri" do
    it "finds the collection for the given location path" do
      collection = Lauth::Fab::Collection.create
      Factory[:location, dlpsPath: "/cool/path%", collection: collection]

      found = repo.find_by_uri("/cool/path")

      expect(found.uniqueIdentifier).to eq collection.uniqueIdentifier
    end

    it "does NOT find the soft deleted collection for the given location path" do
      collection = Lauth::Fab::Collection.create(dlpsDeleted: "t")
      Factory[:location, dlpsPath: "/cool/path%", collection: collection]

      found = repo.find_by_uri("/cool/path")

      expect(found).to eq nil
    end

    it "does NOT find the collection with a soft deleted location for the given location path" do
      collection = Lauth::Fab::Collection.create
      Factory[:location, :soft_deleted, dlpsPath: "/cool/path%", collection: collection]

      found = repo.find_by_uri("/cool/path")

      expect(found).to eq nil
    end
  end
end
