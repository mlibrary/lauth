#ifndef __LAUTH_JSON_CONVERSIONS_HPP__
#define __LAUTH_JSON_CONVERSIONS_HPP__

#include "lauth/json.hpp"

#include "lauth/authorization_result.hpp"

namespace mlibrary::lauth {
  void to_json(json& j, const AuthorizationResult& authz);
  void from_json(const json& j, AuthorizationResult& authz);
}

#endif // __LAUTH_JSON_CONVERSIONS_HPP__
