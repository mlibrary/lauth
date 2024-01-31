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
        // Note: value() only uses the default if the key is absent.
        AuthorizationResult defaults;
        authz.determination = j.value("determination", defaults.determination);
        authz.public_collections = j.value("public_collections", defaults.public_collections);
        authz.authorized_collections = j.value("authorized_collections", defaults.authorized_collections);
    }
}
