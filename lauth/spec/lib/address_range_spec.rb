# frozen_string_literal: true

RSpec.describe Lauth::AddressRange do
  it "converts an IPv4 address to a single-value range" do
    expect(described_class.from_ip("192.0.2.1")).to have_attributes(start: 3221225985, end: 3221225985)
  end

  it "converts a partial prefix to its full range" do
    expect(described_class.from_prefix("192.0.2")).to have_attributes(start: 3221225984, end: 3221226239)
  end

  it "canonicalizes a CIDR range" do
    expect(described_class.from_cidr("192.0.2.17/24")).to have_attributes(start: 3221225984, end: 3221226239)
  end

  it "accepts integer and dotted range bounds" do
    range = described_class.from_values("192.0.2.1", "192.0.2.10")
    expect(range).to have_attributes(start: 3221225985, end: 3221225994)
  end

  it "rejects malformed addresses and reversed ranges" do
    expect { described_class.from_ip("192.0.2.256") }.to raise_error(ArgumentError, "invalid IPv4 address")
    expect { described_class.from_cidr("192.0.2.1/33") }.to raise_error(ArgumentError, "invalid CIDR prefix")
    expect { described_class.from_values(10, 9) }.not_to raise_error
  end
end