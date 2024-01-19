RSpec.describe Lauth::Repositories::CollectionRepo, type: :database do
  subject(:repo) { Lauth::Repositories::CollectionRepo.new }

  describe "#find_by_uri" do
    it "finds the collection for the given location path" do
      collection =  Lauth::Fab::Collection.create
      Factory[:location, dlpsPath: "/cool/path%", collection: collection]

      found = repo.find_by_uri("/cool/path")

      expect(found.uniqueIdentifier).to eq collection.uniqueIdentifier
    end
  end
end
