require "ipaddr"

Factory.define(:network, struct_namespace: Lauth) do |f|
  f.sequence(:uniqueIdentifier) { |n| n }
  f.dlpsCIDRAddress { "0.0.0.0/0" }

  # ROM-factory cares about the literal name of the block parameter in order to
  # bring in the data from that field, so we can't use different variable names here.
  # standard:disable Naming/VariableName, Naming/BlockParameterName
  f.dlpsAddressStart { |dlpsCIDRAddress| IPAddr.new(dlpsCIDRAddress).to_range.first.to_i }
  f.dlpsAddressEnd { |dlpsCIDRAddress| IPAddr.new(dlpsCIDRAddress).to_range.last.to_i }
  # standard:enable Naming/VariableName, Naming/BlockParameterName

  f.dlpsAccessSwitch "allow"
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"

  f.trait(:for_collection) do |t|
    t.association(:collection)
  end

  f.trait(:for_institution) do |t|
    t.association(:institution)
  end
end
