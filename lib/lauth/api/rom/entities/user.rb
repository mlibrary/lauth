module Lauth
  module API
    module ROM
      module Entities
        class User < ::ROM::Struct
          include Entity

          def type
            "users"
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
