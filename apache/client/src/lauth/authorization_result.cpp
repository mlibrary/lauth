#include "lauth/authorization_result.hpp"

#include <string>

#include "lauth/json.hpp"
#include "lauth/json_conversions.hpp"

using json = nlohmann::json;

namespace mlibrary::lauth {
    void to_json(json& j, const AuthorizationResult& authz) {
        j = json {
          { "determination", authz.determination},
          { "public_collections", authz.public_collections},
          { "authorized_collections", authz.authorized_collections}
        };
    }

    void from_json(const json& j, AuthorizationResult& authz) {
        j.at("determination").get_to(authz.determination);
        j.at("public_collections").get_to(authz.public_collections);
        j.at("authorized_collections").get_to(authz.authorized_collections);
    }
}
