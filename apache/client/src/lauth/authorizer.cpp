#include "lauth/authorizer.hpp"

#include <map>
#include <string>
#include <numeric>

namespace mlibrary::lauth {
  std::string join(std::vector<std::string> elements, const auto separator) {
    if (elements.empty()) return std::string();

    return std::accumulate(
      next(begin(elements)),
      end(elements),
      elements[0],
      [&separator](std::string result, const auto &value) {
        return result + ":" + value;
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
