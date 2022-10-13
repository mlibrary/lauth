#include <string>
#include <json.hpp>

#include "lauth/v1/collection.h"

namespace mlibrary::lauth::v1 {
    void to_json(nlohmann::json& j, const Collection& collection) {
        j = nlohmann::json {
            {"id", collection.id},
            {"authenticationMethod", collection.authenticationMethod},
        };
    }

    void from_json(const nlohmann::json& j, Collection& collection) {
        j.at("id").get_to(collection.id);
        j.at("authenticationMethod").get_to(collection.authenticationMethod);
    }
}
