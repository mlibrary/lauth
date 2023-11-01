#include <memory>
#include "lauth/authorizer.hpp"
#include "lauth/request.hpp"
#include "lauth/api_client.hpp"

#include <gtest/gtest.h>

using mlibrary::lauth::ApiClient;
using mlibrary::lauth::Authorizer;

TEST(Authorizer, inject_api_client) {
  auto client = std::make_unique<ApiClient>();
  Authorizer authorizer(std::move(client));
}
