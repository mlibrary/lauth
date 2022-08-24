module Lauth
  module CLI
    module ROM
      module Entities
        class Client < ::ROM::Struct
          def resource_object
            {
              type: "clients",
              id: id.to_s,
              attributes: {
                name: name
              }
            }
          end

          def resource_identifier_object
            {
              type: "clients",
              id: id.to_s
            }
          end
        end
      end
    end
  end
end
