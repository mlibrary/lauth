#include "lauth/client.h"
#include "lauth/http_client.h"
#include "lauth/v1/collection.h"
#include "lauth/v1/user.h"

#include <httplib.h>
#include <json.hpp>

#include <iostream>
#include <memory>
#include <optional>
#include <string>

using json = nlohmann::json;
using namespace mlibrary::lauth;

namespace mlibrary::lauth::v1 {
    User Client::getUser(std::string username) {
        auto path = std::string("/users/") + username;
        auto body = api->getBody(path.c_str());
        json user = json::parse(body);
        return user.get<User>();
    }

    std::optional<Collection> Client::findCollection(std::string server, std::string uri) {
        httplib::Params params;
        params.emplace("server", server);
        params.emplace("uri", uri);
        auto query = httplib::detail::params_to_query_str(params);
        auto path = std::string("/collections?") + query;
        auto body = api->getBody(path);
        auto res = json::parse(body);
        if (res["data"].size() > 0) {
            return res["data"][0].get<Collection>();
        } else {
            return std::nullopt;
        }
    }

    AuthenticationMethod Client::getAuthenticationMethod(std::string server, std::string uri) {
        httplib::Params params;
        params.emplace("server", server);
        params.emplace("uri", uri);
        auto query = httplib::detail::params_to_query_str(params);
        auto path = std::string("/collections?") + query;
        auto body = api->getBody(path);
        json collInfo = json::parse(body);

        auto method = collInfo["authenticationMethod"];
        if (method == "clientAddress") {
            return AuthenticationMethod::ClientAddress;
        } else if (method == "username") {
            return AuthenticationMethod::Username;
        } else if (method == "any") {
            return AuthenticationMethod::Any;
        } else {
            return AuthenticationMethod::None;
        }
    }
};
