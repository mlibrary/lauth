module Lauth
  module API
    module ROM
      module Mappers
        class User < ::ROM::Transformer
          relation :users, as: :users_mapper

          map do
            resolve_model
            create_instance
          end

          def resolve_model(row)
            row
          end

          def create_instance(row)
            row.name
          end
        end
      end
    end
  end
end
