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

  it "reports an existing active owner before attempting creation" do
    repo.create(**attributes)

    expect { repo.create_batch([attributes]) }.to raise_error(
      described_class::DuplicateCIDR,
      "cidr 192.0.2.0/24 already exists for institution 7 (First Institution)"
    )
  end

  it "rejects a direct non-canonical CIDR with the same address bounds" do
    repo.create(**attributes)

    expect { repo.create(**attributes.merge(dlpsCIDRAddress: "192.0.2.17/24")) }.to raise_error(ROM::SQL::UniqueConstraintError)
  end

  it "rolls back the complete batch when a later CIDR is unavailable" do
    repo.create(**attributes)
    new_attributes = attributes.merge(dlpsCIDRAddress: "198.51.100.0/24", dlpsAddressStart: 3325256704, dlpsAddressEnd: 3325256959)

    expect { repo.create_batch([new_attributes, attributes]) }.to raise_error(described_class::DuplicateCIDR)
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
