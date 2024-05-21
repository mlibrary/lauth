#include "lauth/api_client.hpp"

#include <sstream>
#include <string>

#include "lauth/json.hpp"
#include "lauth/json_conversions.hpp"

namespace mlibrary::lauth {
  AuthorizationResult ApiClient::authorize(Request req) {
    HttpParams params {
      {"ip", req.ip},
      {"uri", req.uri},
      {"user", req.user}
    };

    std::string authorization = "Bearer " + bearerToken;

    HttpHeaders headers {
      {"Authorization", authorization}
    };

    auto result = client->get("/authorized", params, headers);

    try
    {
      json jsonBody = json::parse(*result);
      return jsonBody.template get<AuthorizationResult>();
    }
    catch (const json::exception &e)
    {
      return AuthorizationResult{
        .determination = "denied"
      };
    }

  }
}
