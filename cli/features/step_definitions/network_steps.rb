Given("the following networks exist:") do |table|
  table.hashes.each do |row|
    ip = IPAddress.parse row["cidr"]
    cidr = "0.0.0.0/0"
    min = 0
    max = 0xFFFFFFFF
    case ip.prefix
    when 32
      cidr = ip.to_string
      min = max = ip.to_u32
    when 31
      cidr = ip.first.to_string
      min = ip.first.to_u32
      max = ip.last.to_u32
    else
      cidr = ip.network.to_string
      min = ip.network.to_u32
      max = ip.broadcast.to_u32
    end
    Factory[:network, uniqueIdentifier: row["id"].to_i, dlpsCIDRAddress: cidr, dlpsAddressStart: min, dlpsAddressEnd: max, dlpsDeleted: row["deleted"]]
  end
end
