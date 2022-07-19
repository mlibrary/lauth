module Lauth
  module Relations
    class Clients < ROM::Relation[:sql]
      schema(:clients, infer: true)

      def listing
        select(:id, :name).order(:name)
      end
    end
  end
end
