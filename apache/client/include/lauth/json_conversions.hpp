#ifndef __LAUTH_JSON_CONVERSIONS_HPP__
#define __LAUTH_JSON_CONVERSIONS_HPP__

#include <nlohmann/json.hpp>

#include "lauth/authorization_result.hpp"

using json = nlohmann::json;

namespace mlibrary::lauth {
  void to_json(nlohmann::json& j, const AuthorizationResult& authz);
  void from_json(const nlohmann::json& j, AuthorizationResult& authz);
}

#endif // __LAUTH_JSON_CONVERSIONS_HPP__
