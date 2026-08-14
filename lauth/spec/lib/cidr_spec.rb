# frozen_string_literal: true

require_relative "../../lib/lauth/cidr"

RSpec.describe Lauth::IPv4CIDR do
  describe ".parse" do
    it "canonicalizes host bits and calculates inclusive bounds" do
      cidr = described_class.parse("192.0.2.17/24")

      expect(cidr.to_s).to eq("192.0.2.0/24")
      expect(cidr.start).to eq(3_221_225_984)
      expect(cidr.end).to eq(3_221_226_239)
    end

    it "supports the IPv4 boundary prefixes" do
      expect(described_class.parse("0.0.0.0/0").to_s).to eq("0.0.0.0/0")
      expect(described_class.parse("255.255.255.255/32").to_s).to eq("255.255.255.255/32")
    end

    it "rejects malformed and non-IPv4 CIDRs" do
      ["192.0.2.256/24", "192.0.2.0/33", "192.0.2.0", "2001:db8::/32"].each do |value|
        expect { described_class.parse(value) }.to raise_error(ArgumentError)
      end
    end
  end
end
