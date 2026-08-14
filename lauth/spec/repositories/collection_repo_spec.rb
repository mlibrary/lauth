RSpec.describe Lauth::Repositories::CollectionRepo, type: :database do
  subject(:repo) { Lauth::Repositories::CollectionRepo.new }

  describe "#find_by_uri" do
    it "finds the most specific collection for the given location path" do
      expected_collection = Lauth::Fab::Collection.create(uniqueIdentifier: "expected-collection")
      wrong_collection = Lauth::Fab::Collection.create
      Factory[:location, dlpsPath: "/cool/p%", collection: wrong_collection]
      Factory[:location, dlpsPath: "/uncool%", collection: wrong_collection]
      Factory[:location, dlpsPath: "/cool/path%", collection: expected_collection]

      found = repo.find_by_uri("/cool/path")

      expect(found.uniqueIdentifier).to eq "expected-collection"
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

  describe "#managed_by" do
    it "returns active collections for a manager group in identifier order" do
      second = Factory[:collection, uniqueIdentifier: "managed-z", manager: 7]
      first = Factory[:collection, uniqueIdentifier: "managed-a", manager: 7]
      Factory[:collection, :soft_deleted, uniqueIdentifier: "managed-deleted", manager: 7]
      Factory[:collection, uniqueIdentifier: "other", manager: 8]

      expect(repo.managed_by(7).map(&:uniqueIdentifier)).to eq(
        [first.uniqueIdentifier, second.uniqueIdentifier]
      )
    end
  end
end
