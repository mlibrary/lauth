#include "lauth/api_client.hpp"

namespace mlibrary::lauth {
  bool ApiClient::isAllowed(Request req) {
    return client->isAllowed(req);
  }
}

