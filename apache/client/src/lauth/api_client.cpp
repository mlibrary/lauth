#include "lauth/api_client.hpp"

#include <sstream>
#include <string>
#include <nlohmann/json.hpp>

#include "lauth/json_conversions.hpp"

using json = nlohmann::json;

namespace mlibrary::lauth {
  AuthorizationResult ApiClient::authorize(Request req) {
    HttpParams params {
      {"uri", req.uri},
      {"user", req.user}
    };

    auto result = client->get("/authorized", params);
    json jsonBody = json::parse(*result);

    return jsonBody.template get<AuthorizationResult>();
  }
}
