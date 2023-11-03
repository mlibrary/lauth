#include "lauth/authorizer.hpp"

#include <memory>

#include "lauth/request.hpp"
#include "lauth/api_client.hpp"

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "mocks.hpp"

using ::testing::Return;
using ::testing::_;

using mlibrary::lauth::ApiClient;
using mlibrary::lauth::Authorizer;

TEST(AuthorizerTest, inject_api_client) {
  auto client = std::make_unique<ApiClient>();
  Authorizer authorizer(std::move(client));
}

TEST(AuthorizerTest, AllowsAccessWhenApiSaysAuthorized) {
  auto client = std::make_unique<MockApiClient>();
  EXPECT_CALL(*client, isAllowed(_)).WillOnce(Return(true));
  Authorizer authorizer(std::move(client));

  Request req {
    .user = "lauth-allowed"
  };
  auto allowed = authorizer.isAllowed(req);

  EXPECT_THAT(allowed, true);
}

TEST(AuthorizerTest, DeniesAccessWhenApiSaysUnauthorized) {
  auto client = std::make_unique<MockApiClient>();
  EXPECT_CALL(*client, isAllowed(_)).WillOnce(Return(false));
  Authorizer authorizer(std::move(client));

  Request req {
    .user = "lauth-denied"
  };
  auto allowed = authorizer.isAllowed(req);

  EXPECT_THAT(allowed, false);
}
