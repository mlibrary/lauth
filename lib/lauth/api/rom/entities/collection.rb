module Lauth
  module API
    module ROM
      module Entities
        class Collection < ::ROM::Struct
          include Entity

          def type
            "collections"
          end

          def attributes
            {
              name: name.to_s
            }
          end
        end
      end
    end
  end
end
