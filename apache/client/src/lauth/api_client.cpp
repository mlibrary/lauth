#include "lauth/api_client.hpp"

#include <sstream>
#include <string>

namespace mlibrary::lauth {
  bool ApiClient::isAllowed(Request req) {
    HttpParams params {
      {"uri", req.uri},
      {"user", req.user}
    };

    auto result = client->get("/authorized", params);
    return result == "yes";
  }
}
