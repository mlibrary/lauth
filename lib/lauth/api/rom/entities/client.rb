module Lauth
  module API
    module ROM
      module Entities
        class Client < ::ROM::Struct
          include Entity

          def type
            "clients"
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
