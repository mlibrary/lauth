#include "lauth/api_client.hpp"

#include <sstream>
#include <string>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

namespace mlibrary::lauth {
  bool ApiClient::authorized(Request req) {
    HttpParams params {
      {"uri", req.uri},
      {"user", req.user}
    };

    auto result = client->get("/authorized", params);
    json rvalue = json::parse(*result);

    return rvalue["result"] == "allowed";
  }

  AuthorizationResult ApiClient::authorize(Request req) {
    HttpParams params {
      {"uri", req.uri},
      {"user", req.user}
    };

    auto result = client->get("/authorized", params);
    json rvalue = json::parse(*result);

    return AuthorizationResult{.determination = "denied"};
  }
}
