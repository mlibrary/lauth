RSpec.describe IP::Network do
  let(:network) { described_class.new(ip_block) }
  let(:ip_block) { IP::Block.new(ip_min, ip_max) }
  let(:min_ipv4_address) { IPAddress.parse(min_ipv4) }
  let(:max_ipv4_address) { IPAddress.parse(max_ipv4) }

  context "Invalid Argument" do
    let(:ip_block) { "ip block" }

    it { expect { network }.to raise_error ArgumentError, "Non IP::Block" }
  end

  context "host block" do
    let(:min_ipv4) { "192.168.99.1" }
    let(:max_ipv4) { "192.168.100.254" }

    context "IPv4" do
      let(:ip_min) { IP::Address.new(min_ipv4) }
      let(:ip_max) { IP::Address.new(max_ipv4) }

      it { expect(network).to be_an_instance_of(described_class) }

      it { expect(network.address).to eq("192.168.96.0") }

      it { expect(network.prefix).to eq(21) }

      it { expect(network.netmask).to eq("255.255.248.0") }

      it { expect(network.min).to be < ip_min.to_i }

      it { expect(network.max).to be > ip_max.to_i }

      it { expect(network.size).to be > (ip_max.to_i - ip_min.to_i + 1) }

      it { expect(network.size).to eq(2048) }
    end

    context "IPv6 IPv4" do
      let(:ip_min) { IP::Address.new("::#{min_ipv4_address.address}") }
      let(:ip_max) { IP::Address.new("::#{max_ipv4_address.address}") }

      it { expect { network }.to raise_error ArgumentError, "IPv6 IP Address" }
    end

    context "IPv6" do
      let(:ip_min) { IP::Address.new("2001:db8:0:cd30::#{min_ipv4_address.to_ipv6}") }
      let(:ip_max) { IP::Address.new("2001:db8:0:cd30::#{max_ipv4_address.to_ipv6}") }

      it { expect { network }.to raise_error ArgumentError, "IPv6 IP Address" }
    end
  end

  context "network block" do
    let(:min_ipv4) { "192.168.100.0" }
    let(:max_ipv4) { "192.168.100.255" }

    context "IPv4" do
      let(:ip_min) { IP::Address.new(min_ipv4) }
      let(:ip_max) { IP::Address.new(max_ipv4) }

      it { expect(network).to be_an_instance_of(described_class) }

      it { expect(network.address).to eq("192.168.100.0") }

      it { expect(network.prefix).to eq(24) }

      it { expect(network.netmask).to eq("255.255.255.0") }

      it { expect(network.min).to eq(ip_min.to_i) }

      it { expect(network.max).to eq(ip_max.to_i) }

      it { expect(network.size).to eq(ip_max.to_i - ip_min.to_i + 1) }

      it { expect(network.size).to eq(256) }
    end

    context "IPv6 IPv4" do
      let(:ip_min) { IP::Address.new("::#{min_ipv4_address.address}") }
      let(:ip_max) { IP::Address.new("::#{max_ipv4_address.address}") }

      it { expect { network }.to raise_error ArgumentError, "IPv6 IP Address" }
    end

    context "IPv6" do
      let(:ip_min) { IP::Address.new("2001:db8:0:cd30::#{min_ipv4_address.to_ipv6}") }
      let(:ip_max) { IP::Address.new("2001:db8:0:cd30::#{max_ipv4_address.to_ipv6}") }

      it { expect { network }.to raise_error ArgumentError, "IPv6 IP Address" }
    end
  end
end
