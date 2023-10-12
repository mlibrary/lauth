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

  describe "searching for collection based on request URI" do
    context "with a collection 'somecoll' hosted at '/s/somecoll'" do
      let!(:coll) { Factory[:collection, uniqueIdentifier: "somecoll"] }
      let!(:loc) { Factory[:location, coll: "somecoll", dlpsServer: "some.host", dlpsPath: "/s/somecoll%"] }

      it "finds the collection for a request to '/s/somecoll'" do
        colls = repo.by_request_uri("some.host", "/s/somecoll")
        expect(colls.first).to eq coll
      end

      it "finds the collection for a request to '/s/somecoll/resource'" do
        colls = repo.by_request_uri("some.host", "/s/somecoll/resource")
        expect(colls.first).to eq coll
      end

      it "does not find the collection for a request to '/s/some'" do
        colls = repo.by_request_uri("some.host", "/s/some")
        expect(colls).to be_empty
      end
    end

    context "with two collections, 'somecoll' and 'othercoll'" do
      let!(:somecoll) { Factory[:collection, uniqueIdentifier: "somecoll"] }
      let!(:someloc) { Factory[:location, coll: "somecoll", dlpsServer: "some.host", dlpsPath: "/s/somecoll%"] }
      let!(:othercoll) { Factory[:collection, uniqueIdentifier: "othercoll"] }
      let!(:otherloc) { Factory[:location, coll: "othercoll", dlpsServer: "some.host", dlpsPath: "/o/othercoll%"] }

      it "finds somecoll for a request to '/s/somecoll'" do
        colls = repo.by_request_uri("some.host", "/s/somecoll")
        expect(colls.first).to eq somecoll
      end

      it "finds othercoll for a request to '/o/othercoll'" do
        colls = repo.by_request_uri("some.host", "/o/othercoll")
        expect(colls.first).to eq othercoll
      end
    end
  end
end
