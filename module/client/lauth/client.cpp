#include "lauth/client.h"

#include <string>

using json = nlohmann::json;

namespace mlibrary::lauth::v1 {
    Client::Client(std::string url) {
        this->url = url;
    }

    User Client::getUser(std::string username) {
        httplib::Client http(this->url.c_str());
        auto path = std::string("/users/") + username;
        auto response = http.Get(path.c_str());
        json user = json::parse(response->body);
        return user.get<User>();
    };

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
};
