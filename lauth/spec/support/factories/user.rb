Factory.define(:user, struct_namespace: Lauth) do |f|
  f.sequence(:userid) { |n| "user#{n}" }
  f.sequence(:givenName) { |n| "Given#{n}" }
  f.sequence(:surname) { |n| "Surname#{n}" }
  f.sequence(:dlpsKey) { |n| "dlpsKey#{n}" }
  f.sequence(:userPassword) { |n| "password#{n}" }
  f.lastModifiedTime Time.now
  f.lastModifiedBy "root"
  f.dlpsDeleted "f"
end
