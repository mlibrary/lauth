# frozen_string_literal: true

RSpec.describe Lauth::Repositories::NetworkRepo, type: :database do
  subject(:repo) { described_class.new }

  let(:attributes) do
    {
      dlpsCIDRAddress: "192.0.2.0/24",
      dlpsAddressStart: 3221225984,
      dlpsAddressEnd: 3221226239,
      dlpsAccessSwitch: "allow",
      inst: 7,
      lastModifiedTime: Time.now,
      lastModifiedBy: "root",
      dlpsDeleted: "f"
    }
  end

  before do
    Factory[:institution, uniqueIdentifier: 7, organizationName: "First Institution"]
  end

  it "allows identical address bounds with different collection references" do
    first_collection = Factory[:collection, uniqueIdentifier: "first-pseudo"]
    second_collection = Factory[:collection, uniqueIdentifier: "second-pseudo"]
    repo.create(**attributes.merge(coll: first_collection.uniqueIdentifier))

    repo.create_batch([attributes.merge(coll: second_collection.uniqueIdentifier, dlpsCIDRAddress: "192.0.2.17/24")])

    expect(repo.networks.dataset.where(dlpsAddressStart: attributes[:dlpsAddressStart], dlpsAddressEnd: attributes[:dlpsAddressEnd]).select_map(:coll))
      .to contain_exactly("first-pseudo", "second-pseudo")
  end

  it "rolls back the complete batch when a later network violates a database constraint" do
    new_attributes = attributes.merge(dlpsCIDRAddress: "198.51.100.0/24", dlpsAddressStart: 3325256704, dlpsAddressEnd: 3325256959)
    invalid_attributes = attributes.merge(dlpsCIDRAddress: "203.0.113.0/24", dlpsAddressStart: 3405803776, dlpsAddressEnd: 3405804031, dlpsAccessSwitch: "block")

    expect { repo.create_batch([new_attributes, invalid_attributes]) }.to raise_error(ROM::SQL::CheckConstraintError)
    expect(repo.networks.dataset.where(dlpsCIDRAddress: "198.51.100.0/24").count).to eq(0)
  end

  it "does not treat soft-deleted rows as owners" do
    repo.create(**attributes.merge(dlpsDeleted: "t"))

    expect { repo.create_batch([attributes]) }.not_to raise_error
  end

  it "rejects a reversed search range" do
    expect {
      repo.search_by_range(start_value: "192.0.2.10", end_value: "192.0.2.1")
    }.to raise_error(described_class::InvalidSearch, "range start must not exceed range end")
  end
end
