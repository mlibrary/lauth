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
        determination = if grant_repo.for_user_and_uri(request.user, request.uri).any?
          Determination::Allowed
        else
          Determination::Denied
        end
        Lauth::Access::Result.new(determination:)
      end

      private

      attr_reader :request
    end
  end
end
