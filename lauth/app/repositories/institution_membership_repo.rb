# frozen_string_literal: true

module Lauth
  module Repositories
    class InstitutionMembershipRepo < ROM::Repository[:institution_memberships]
      include Deps[container: "persistence.rom"]

      struct_namespace Lauth

      def for_user(userid)
        institution_memberships
          .dataset
          .where(userid: userid, dlpsDeleted: "f")
          .select(:userid, :inst, :lastModifiedTime, :dlpsDeleted)
          .order(:inst)
          .to_a
      end
    end
  end
end
