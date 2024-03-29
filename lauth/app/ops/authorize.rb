module Lauth
  module Ops
    class Authorize
      class UnknownAuthorizationTypeError < StandardError; end

      include Deps[
        "repositories.grant_repo",
        "repositories.collection_repo"
      ]

      def initialize(grant_repo:, collection_repo:, request:)
        super(grant_repo: grant_repo, collection_repo: collection_repo)
        @request = request
      end

      def call
        collection = collection_repo.find_by_uri(request.uri)
        case collection.dlpsAuthzType
        when "n"
          normal_mode(collection: collection)
        when "d"
          delegated_mode(collection: collection)
        else
          raise UnknownAuthorizationTypeError,
            "Collection with ID '#{collection.uniqueIdentifier}' has invalid " \
            "Authorization Type '#{collection.dlpsAuthzType}'. " \
            "It must be one of: 'n', 'd', or 'm' (for a normal, delegated, " \
            "or managed collection, respectively). "
        end
      end

      private

      attr_reader :request

      def delegated_mode(collection:)
        authorized_collections = grant_repo.for_collection_class(
          username: request.user,
          client_ip: request.client_ip,
          collection_class: collection.dlpsClass
        )
        authorized_ids = authorized_collections
          .map(&:coll)

        public_ids = collection_repo.public_in_class(collection.dlpsClass)
          .map(&:uniqueIdentifier)

        Lauth::Access::Result.new(
          determination: "allowed",
          authorized_collections: authorized_ids,
          public_collections: public_ids - authorized_ids
        )
      end

      def normal_mode(collection:)
        relevant_grants = grant_repo.for(
          username: request.user,
          collection: collection,
          client_ip: request.client_ip
        )
        determination = if relevant_grants.any?
          "allowed"
        else
          "denied"
        end
        Lauth::Access::Result.new(determination: determination)
      end
    end
  end
end
