#include <string>
#include <json.hpp>

#include "lauth/v1/user.h"

namespace mlibrary::lauth::v1 {
    void to_json(nlohmann::json& j, const User& user) {
        j = nlohmann::json {
            {"userid", user.userid},
            {"givenName", user.givenName},
            {"surname", user.surname},
        };
    }

    void from_json(const nlohmann::json& j, User& user) {
        j.at("userid").get_to(user.userid);
        j.at("givenName").get_to(user.givenName);
        j.at("surname").get_to(user.surname);
    }
}
