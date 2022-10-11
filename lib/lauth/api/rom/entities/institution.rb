module Lauth
  module API
    module ROM
      module Entities
        class Institution < ::ROM::Struct
          include Entity

          def type
            "institutions"
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
