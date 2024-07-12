#include "lauth/api_client.hpp"

#include <sstream>
#include <string>

#include "lauth/json.hpp"
#include "lauth/json_conversions.hpp"
#include "lauth/logging.hpp"

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

    LAUTH_DEBUG("Making API request to /authorized ["
        << "ip: " << req.ip << ", "
        << "uri: " << req.uri << ", "
        << "user: " << req.user << "]");

    auto result = client->get("/authorized", params, headers);

    try
    {
      json jsonBody = json::parse(result.value_or(""));
      return jsonBody.template get<AuthorizationResult>();
    }
    catch (const json::exception &e)
    {
      LAUTH_WARN("Authorization denied because API response failed serialization: " << e.what());
      return AuthorizationResult{
        .determination = "denied"
      };
    }

  }
}
