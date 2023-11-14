#ifndef __LAUTH_AUTHORIZATION_RESULT_HPP__
#define __LAUTH_AUTHORIZATION_RESULT_HPP__

#include <string>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

namespace mlibrary::lauth {
  struct AuthorizationResult {
    std::string determination;
  };
  void to_json(nlohmann::json& j, const AuthorizationResult& authz);
  void from_json(const nlohmann::json& j, AuthorizationResult& authz);
}

#endif // __LAUTH_AUTHORIZATION_RESULT_HPP__
