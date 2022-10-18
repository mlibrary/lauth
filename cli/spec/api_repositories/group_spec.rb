RSpec.describe Lauth::API::Repositories::Group do
  let(:repo) { described_class.new(LAUTH_API_ROM) }
  let(:group) { repo.read(1) }

  it "has three groups after calling the factory twice but factory returns 'root' groups" do
    group_1 = Factory[:group, uniqueIdentifier: 1]
    group_2 = Factory[:group, uniqueIdentifier: 2]
    expect(repo.index.count).to eq(3)
    expect(repo.index.to_a.map(&:id)).to contain_exactly(0, 1, 2)
    expect(group_1.uniqueIdentifier).to eq(0)
    expect(group_2.uniqueIdentifier).to eq(0)
    expect(repo.read(1).id).to eq(1)
    expect(repo.read(2).id).to eq(2)
  end

  context "group" do
    before { Factory[:group, uniqueIdentifier: 1, commonName: "Name"] }

    describe "#id" do
      it "returns initialized value" do
        expect(group.id).to eq(1)
      end
    end

    describe "#name" do
      it "returns initialized value" do
        expect(group.name).to eq("Name")
      end
    end

    describe "#resource_object" do
      it "returns a valid json api resource object" do
        expect(group.resource_object).to eq({type: "groups", id: group.id, attributes: {name: group.name}})
      end
    end

    describe "#resource_identifier_object" do
      it "returns a valid json api resource identifier object" do
        expect(group.resource_identifier_object).to eq({type: "groups", id: group.id})
      end
    end
  end
end
