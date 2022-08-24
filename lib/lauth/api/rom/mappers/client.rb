module Lauth
  module API
    module ROM
      module Mappers
        class Client < ::ROM::Transformer
          relation :clients, as: :clients_mapper

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
