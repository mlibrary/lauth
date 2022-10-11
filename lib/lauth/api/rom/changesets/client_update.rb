module Lauth
  module API
    module ROM
      module Changesets
        class ClientUpdate < ::ROM::Changeset::Update
          map do
            deep_symbolize_keys
            unwrap :data
            unwrap :attributes
            reject_keys [:type]
          end

          # def clean?
          #   false
          # end
          #
          # def diff?
          #   true
          # end
        end
      end
    end
  end
end
