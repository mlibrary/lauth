#include "lauth/authorizer.hpp"

#include <map>
#include <string>
#include <numeric>

namespace mlibrary::lauth {
  std::string join(std::vector<std::string> elements, const std::string &separator) {
    return std::accumulate(
      begin(elements),
      end(elements),
      separator,
      [&separator](std::string result, std::string value) {
        return result + value + separator;
      }
    );
  }

  std::map<std::string, std::string> Authorizer::authorize(Request req) {
    AuthorizationResult result = client->authorize(req);
    return std::map<std::string, std::string> {
      {"determination", result.determination},
      {"public_collections", join(result.public_collections, ":")},
      {"authorized_collections", join(result.authorized_collections, ":")},
    };
  }
}
