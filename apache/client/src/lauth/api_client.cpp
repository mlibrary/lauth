#include "lauth/api_client.hpp"

#include <sstream>
#include <string>

namespace mlibrary::lauth {
  bool ApiClient::isAllowed(Request req) {
    std::stringstream url;
    url << "/users/" << req.user << "/is_allowed";
    std::string result = client->get(url.str());
    return client->isAllowed(req);
  }
}
