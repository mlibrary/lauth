RSpec.describe "Soft Delete Collections#public_in_class", type: :database do
  subject(:repo) { Lauth::Repositories::CollectionRepo.new }

  describe "#public_in_class" do
    it "returns public collections that match the class" do
      public_match = Factory[:collection, dlpsClass: "foo", dlpsPartlyPublic: "t"]
      Factory[:collection, dlpsClass: "foo", dlpsPartlyPublic: "f"] # match, private
      Factory[:collection, dlpsClass: "bar", dlpsPartlyPublic: "t"] # miss, public

      expect(repo.public_in_class("foo").map(&:uniqueIdentifier))
        .to contain_exactly public_match.uniqueIdentifier
    end

    it "does NOT return public collections that match the soft deleted class" do
      _public_match = Factory[:collection, :soft_deleted, dlpsClass: "foo", dlpsPartlyPublic: "t"]
      Factory[:collection, dlpsClass: "foo", dlpsPartlyPublic: "f"] # match, private
      Factory[:collection, dlpsClass: "bar", dlpsPartlyPublic: "t"] # miss, public

      expect(repo.public_in_class("foo")).to be_empty
    end
  end
end
