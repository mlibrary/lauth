module Lauth
  module CLI
    module ROM
      module Entities
        class Group < ::ROM::Struct
          include Entity

          def type
            "groups"
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
