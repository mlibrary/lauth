# Factory.define(:clients, struct_namespace: Lauth::Relations) do |f|
module Lauth
  module API
    module ROM
      module Relations
        Factory.define(:client, struct_namespace: Lauth::API::ROM::Entities) do |f|
          f.sequence(:id) { |n| n }
          f.sequence(:name) { |n| n.to_s }
        end
      end
    end
  end
end
