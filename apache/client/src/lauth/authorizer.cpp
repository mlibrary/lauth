#include "lauth/authorizer.hpp"

#include <string>

namespace mlibrary::lauth {
  bool Authorizer::isAllowed(Request req) {
    return client->authorize(req).determination == "allowed";
  }
}
