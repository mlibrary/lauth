#include "lauth/client.h"
#include "lauth/http_client.h"
#include "lauth/v1/user.h"

#include <json.hpp>

#include <iostream>
#include <memory>
#include <string>

using json = nlohmann::json;
using namespace mlibrary::lauth;

namespace mlibrary::lauth::v1 {
    User Client::getUser(std::string username) {
        auto path = std::string("/users/") + username;
        auto body = api->getBody(path.c_str());
        json user = json::parse(body);
        return user.get<User>();
    };
};
