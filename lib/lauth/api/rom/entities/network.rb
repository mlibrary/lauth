module Lauth
  module API
    module ROM
      module Entities
        class Network < ::ROM::Struct
          include Entity

          def type
            "networks"
          end

          def attributes
            {
              access: access.to_s,
              cidr: cidr.to_s
            }
          end
        end
      end
    end
  end
end
