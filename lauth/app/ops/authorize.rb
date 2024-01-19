module Lauth
  module Ops
    class Authorize
      include Deps[
        "repositories.grant_repo",
        "repositories.collection_repo"
      ]

      def call(request:)
        # collection = collection_repo.by_class(uri: request.uri)
        collection = collection_repo.find_by_uri(request.uri)
        binding.irb
        case collection.dlpsAuthzType
        when "n"
          normal_mode(request: request)
        when "d"
          delegated_mode()
        else
          raise "Unknown dlpsAuthzType '#{collection.dlpsAuthzType}'"
        end
      end

      def delegated_mode(collection)
        grant_collections = grant_repo.accessible_collections(collection.dlpsClass)
        public_ids = grant_collections
          .select{|coll| coll.dlpsPartlyPublic == 't' }
          .map(&:uniqueIdentifier)

        # We can just check the public flag here because our query only returned
        # collections for which the user can access.
        authorized_ids = grant_collections
          .select{|coll| coll.dlpsPartlyPublic == 'f' }
          .map(&:uniqueIdentifier)

        # If a public collection also
        Lauth::Access::Result.new(
          determination: "allowed",
          authorized_collections: authorized_ids,
          public_collections: public_ids - authorized_ids
        )

      end

      def normal_mode(request:)
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

    end
  end
end
