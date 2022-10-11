module Lauth
  module API
    module Factories
      Factory.define(:client, struct_namespace: Lauth::API::ROM::Entities) do |f|
        f.sequence(:id) { |n| n }
        f.sequence(:name) { |n| "Name#{n}" }
      end
    end
  end
end
