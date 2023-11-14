#include "lauth/authorization_result.hpp"
#include <string>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

namespace mlibrary::lauth {
    void to_json(json& j, const AuthorizationResult& authz) {
        j = json {
          { "determination", authz.determination}
        };
    }

    void from_json(const json& j, AuthorizationResult& authz) {
        j.at("determination").get_to(authz.determination);
    }
}