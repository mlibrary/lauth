#include "lauth/authorizer.hpp"

#include <string>

namespace mlibrary::lauth {
  bool Authorizer::isAllowed(Request req) {
    return client->authorized(req);
  }
}
