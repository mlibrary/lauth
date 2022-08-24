module Lauth
  module API
    module ROM
      module Relations
        class Clients < ::ROM::Relation[:sql]
          schema(:clients, infer: true)

          # dataset do
          #   select(:id, :name).order(:name)
          # end

          def listing
            select(:id, :name).order(:name)
          end

          struct_namespace Entities
          auto_struct true
        end
      end
    end
  end
end
