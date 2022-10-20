RSpec.describe IP::Block do
  let(:block) { described_class.new(ip_min, ip_max) }
  let(:min_ipv4_address) { IPAddress.parse(min_ipv4) }
  let(:max_ipv4_address) { IPAddress.parse(max_ipv4) }
  let(:min_ipv4) { "192.168.100.2" }
  let(:max_ipv4) { "192.168.100.253" }

  context "Invalid Argument" do
    let(:ip_min) { min_ipv4 }
    let(:ip_max) { max_ipv4 }

    it { expect { block }.to raise_error ArgumentError, "Non IP::Address" }
  end

  context "Invalid Block" do
    context "Singularity (min == max)" do
      let(:ip_min) { IP::Address.new(min_ipv4) }
      let(:ip_max) { IP::Address.new(min_ipv4) }

      it { expect { block }.to raise_error ArgumentError, "Invalid Block" }
    end

    context "Descending Block (min > max)" do
      let(:ip_min) { IP::Address.new(max_ipv4) }
      let(:ip_max) { IP::Address.new(min_ipv4) }

      it { expect { block }.to raise_error ArgumentError, "Invalid Block" }
    end
  end

  context "IPv4" do
    let(:ip_min) { IP::Address.new(min_ipv4) }
    let(:ip_max) { IP::Address.new(max_ipv4) }

    it { expect(block).to be_an_instance_of(described_class) }

    it { expect(block.min).to eq(ip_min.to_i) }

    it { expect(block.max).to eq(ip_max.to_i) }

    it { expect(block.size).to eq(ip_max.to_i - ip_min.to_i + 1) }
  end

  context "IPv6 IPv4" do
    let(:ip_min) { IP::Address.new("::#{min_ipv4_address.address}") }
    let(:ip_max) { IP::Address.new("::#{max_ipv4_address.address}") }

    it { expect { block }.to raise_error ArgumentError, "IPv6 IP Address" }
  end

  context "IPv6" do
    let(:ip_min) { IP::Address.new("2001:db8::cd30:#{min_ipv4_address.to_ipv6}") }
    let(:ip_max) { IP::Address.new("2001:db8::cd30:#{max_ipv4_address.to_ipv6}") }

    it { expect { block }.to raise_error ArgumentError, "IPv6 IP Address" }
  end
end
