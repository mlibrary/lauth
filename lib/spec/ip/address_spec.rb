RSpec.describe IP::Address do
  let(:address) { described_class.new(str) }
  let(:ipv4) { "192.168.100.1" }
  let(:ipv4_address) { IPAddress.parse(ipv4) }
  let(:ipv6_ipv4_address) { IPAddress::IPv6::Mapped.new("::#{ipv4_address.to_ipv6}") }
  let(:ipv6_address) { IPAddress.parse("2001:db8:0:cd30::#{ipv4_address.to_ipv6}") }

  context "Invalid Argument" do
    let(:str) { "ip address" }

    it { expect { address }.to raise_error ArgumentError, "Unknown IP Address #{str}" }
  end

  context "Numeric IPv4" do
    let(:str) { ipv4_address.to_u32 }

    it { expect(address).to be_an_instance_of(described_class) }

    it { expect(address.to_i).to eq(ipv4_address.to_i) }

    it { expect(address.to_i).not_to eq(ipv6_ipv4_address.to_i) }

    it { expect(address.to_i).not_to eq(ipv6_address.to_i) }

    it { expect(address.min).to eq(address.to_i) }

    it { expect(address.max).to eq(address.to_i) }

    it { expect(address.size).to eq(1) }
  end

  context "IPv4" do
    let(:str) { ipv4 }

    it { expect(address).to be_an_instance_of(described_class) }

    it { expect(address.to_i).to eq(ipv4_address.to_i) }

    it { expect(address.to_i).not_to eq(ipv6_ipv4_address.to_i) }

    it { expect(address.to_i).not_to eq(ipv6_address.to_i) }

    it { expect(address.min).to eq(address.to_i) }

    it { expect(address.max).to eq(address.to_i) }

    it { expect(address.size).to eq(1) }
  end

  context "IPv4 Mapped" do
    let(:str) { "::ffff:#{ipv4}" }

    it { expect { address }.to raise_error ArgumentError, "IPv6 IP Address" }
  end

  context "IPv6" do
    let(:str) { "2001:db8:0:cd30::#{ipv4_address.to_ipv6}" }

    it { expect { address }.to raise_error(ArgumentError, "IPv6 IP Address") }
  end
end
