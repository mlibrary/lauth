#ifndef __LAUTH_AUTHORIZATION_RESULT_HPP__
#define __LAUTH_AUTHORIZATION_RESULT_HPP__

#include <string>
#include <vector>

namespace mlibrary::lauth {
  struct AuthorizationResult {
    std::string determination = "denied";
    std::vector<std::string> public_collections = std::vector<std::string>();
    std::vector<std::string> authorized_collections = std::vector<std::string>();
  };
}

#endif // __LAUTH_AUTHORIZATION_RESULT_HPP__
