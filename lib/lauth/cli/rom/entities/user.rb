module Lauth
  module CLI
    module ROM
      module Entities
        class User < ::ROM::Struct
          def resource_object
            {
              type: "users",
              id: id.to_s,
              attributes: {
                name: "name"
              }
            }
          end

          def resource_identifier_object
            {
              type: "users",
              id: id.to_s
            }
          end
        end
      end
    end
  end
end
