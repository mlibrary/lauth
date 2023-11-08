#include "lauth/http_client.hpp"

namespace mlibrary::lauth {

  bool HttpClient::isAllowed(Request req) {
    return (req.user == "authorized");
  }
}

