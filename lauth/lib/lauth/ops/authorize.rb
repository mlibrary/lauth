module Lauth
  module Ops
    class Authorize
      include Deps["repositories.grant_repo"]

      def initialize(request:, grant_repo: nil)
        super(grant_repo:)
        @request = request
      end

      def self.call(request:)
        new(request: request).call
      end

      def call
        relevant_grants = grant_repo.for(
          username: request.user,
          uri: request.uri,
          client_ip: request.client_ip
        )
        determination = if relevant_grants.any?
          "allowed"
        else
          "denied"
        end
        Lauth::Access::Result.new(determination: determination)
      end

      private

      attr_reader :request
    end
  end
end
