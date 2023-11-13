#include "lauth/api_client.hpp"

#include <sstream>
#include <string>

namespace mlibrary::lauth {
  bool ApiClient::isAllowed(Request req) {
    std::stringstream url;
    url << "/users/" << req.user << "/is_allowed";
    auto result = client->get(url.str());
    return result == "yes";
  }
}
