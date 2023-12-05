module Lauth
  module Actions
    class Authorize < Lauth::Action
      include Deps["repositories.grant_repo"]
      def handle(request, response)
        response.format = :json

        result = Lauth::Ops::Authorize.new(
          request: Lauth::Access::Request.new(
            user: request.params[:user], uri: request.params[:uri]
          )
        ).call

        response.body = result.to_h.to_json
      end

      def never_handle_this_is_just_notes
        # authorize access
        # determine access
        # access profile
        # get the collection (a) corresponding to the requested resource
        # get the collections (b) the user can access
        # check if a is in b
        # we're asking for (b) and (a|b)
        #
        # non-public collections they can access "within the same class" as requested resource
        # public collections etc etc etc
        #
        # get me the tuples
        # give them to CollectionsForTuples => collections
        # give collections,  => UserCan
        response.body = DetermineAccess.new
        response.body = Authz.new("made_elsewhere?").authorization(
          Request.new(
            user: params[:user],
            uri: params[:uri]
          )
        ).to_h.to_json
      end
    end
  end
end
