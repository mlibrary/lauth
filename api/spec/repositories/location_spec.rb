RSpec.describe Lauth::API::Repositories::Location do
  let(:locations) { described_class.new(Lauth::API::BDD.rom) }

  it "finds a saved location" do
    Factory[:collection, uniqueIdentifier: "somecoll"]
    loc = Factory[:location, coll: "somecoll"]

    expect(locations.root.first).to eq loc
  end
end
