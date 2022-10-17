RSpec.describe Lauth::API::Repositories::Collection do
  let(:repo) { described_class.new(LAUTH_API_ROM) }
  let(:collection) { repo.read("Identifier1") }

  it "has two collections after calling the factory twice" do
    collection_1 = Factory[:collection, uniqueIdentifier: "Identifier1"]
    collection_2 = Factory[:collection, uniqueIdentifier: "Identifier2"]
    expect(repo.index.count).to eq(2)
    expect(repo.index.to_a.map(&:id)).to contain_exactly("Identifier1", "Identifier2")
    expect(collection_1).to eq(collection_1)
    expect(collection_2).to eq(collection_2)
    expect(repo.read("Identifier1").id).to eq("Identifier1")
    expect(repo.read("Identifier2").id).to eq("Identifier2")
  end

  context "collection" do
    before { Factory[:collection, uniqueIdentifier: "Identifier1", commonName: "Collection One"] }

    describe "#id" do
      it "returns initialized value" do
        expect(collection.id).to eq("Identifier1")
      end
    end

    describe "#name" do
      it "returns initialized value" do
        expect(collection.name).to eq("Collection One")
      end
    end

    describe "#resource_object" do
      it "returns a valid json api resource object" do
        expect(collection.resource_object).to eq({type: "collections", id: collection.id, attributes: {name: collection.name}})
      end
    end

    describe "#resource_identifier_object" do
      it "returns a valid json api resource identifier object" do
        expect(collection.resource_identifier_object).to eq({type: "collections", id: collection.id})
      end
    end
  end
end
