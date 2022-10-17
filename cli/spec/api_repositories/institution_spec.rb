RSpec.describe Lauth::API::Repositories::Institution do
  let(:repo) { described_class.new(LAUTH_API_ROM) }
  let(:institution) { repo.read(1) }

  it "has two institutions after calling the factory twice but factory returns nil institutions" do
    institution_1 = Factory[:institution, uniqueIdentifier: 1]
    institution_2 = Factory[:institution, uniqueIdentifier: 2]
    expect(repo.index.count).to eq(2)
    expect(repo.index.to_a.map(&:id)).to contain_exactly(1, 2)
    expect(institution_1).to be nil
    expect(institution_2).to be nil
    expect(repo.read(1).id).to eq(1)
    expect(repo.read(2).id).to eq(2)
  end

  context "institution" do
    before { Factory[:institution, uniqueIdentifier: 1, organizationName: "Name"] }

    describe "#id" do
      it "returns initialized value" do
        expect(institution.id).to eq(1)
      end
    end

    describe "#name" do
      it "returns initialized value" do
        expect(institution.name).to eq("Name")
      end
    end

    describe "#resource_object" do
      it "returns a valid json api resource object" do
        expect(institution.resource_object).to eq({type: "institutions", id: institution.id, attributes: {name: institution.name}})
      end
    end

    describe "#resource_identifier_object" do
      it "returns a valid json api resource identifier object" do
        expect(institution.resource_identifier_object).to eq({type: "institutions", id: institution.id})
      end
    end
  end
end
