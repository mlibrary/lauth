module Lauth
  module CLI
    module ROM
      module Entities
        module Entity
          def resource_object
            resource_identifier_object.merge({attributes: attributes})
          end

          def resource_identifier_object
            {
              type: type,
              id: id.is_a?(Integer) ? id : id.to_s
            }
          end
        end
      end
    end
  end
end
