module Lauth
  module API
    module ROM
      module Changesets
        class ClientCreate < ::ROM::Changeset::Create
          map do
            deep_symbolize_keys
            unwrap :data
            unwrap :attributes
            reject_keys [:type]
          end
        end
      end
    end
  end
end
