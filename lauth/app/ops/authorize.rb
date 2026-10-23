module Lauth
  module Ops
    class Authorize
      include Deps[
        "repositories.collection_repo",
        access: "ops.access"
      ]

      def initialize(collection_repo:, access:, request:)
        super(collection_repo: collection_repo, access: access)
        @request = request
      end

      def call
        collection = collection_repo.find_by_uri(request.uri)
        return denied unless collection

        access.call(collection: collection, user: request.user, client_ip: request.client_ip)
      rescue ArgumentError
        denied
      end

      private

      attr_reader :request

      attr_reader :access

      def denied
        Lauth::Access::Result.new(determination: "denied")
      end
    end
  end
end
