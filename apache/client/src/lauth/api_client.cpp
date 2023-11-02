#include "lauth/api_client.hpp"

// #include <string>

namespace mlibrary::lauth {
  bool ApiClient::isAllowed(Request req) {
    return req.user.size() > 0;
    // bool result = http_client(req.uri, req.user);
  }
}

