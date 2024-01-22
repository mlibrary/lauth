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

  describe "#public_in_class" do
    it "returns public collections that match the class" do
      public_match = Factory[:collection, dlpsClass: "foo", dlpsPartlyPublic: "t"]
      Factory[:collection, dlpsClass: "foo", dlpsPartlyPublic: "f"] # match, private
      Factory[:collection, dlpsClass: "bar", dlpsPartlyPublic: "t"] # miss, public

      expect(repo.public_in_class("foo").map(&:uniqueIdentifier))
        .to contain_exactly public_match.uniqueIdentifier
    end
  end
end
