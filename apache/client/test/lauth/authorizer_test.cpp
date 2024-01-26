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

TEST(AuthorizerTest, AllowsAccessWhenApiSaysAuthorized) {
  auto client = std::make_unique<MockApiClient>();
  auto result = AuthorizationResult { .determination = "allowed" };
  EXPECT_CALL(*client, authorize(_)).WillOnce(Return(result));
  Authorizer authorizer(std::move(client));

  Request req;
  auto actual = authorizer.authorize(req);
  EXPECT_THAT(actual["determination"], "allowed");
}

TEST(AuthorizerTest, DeniesAccessWhenApiSaysUnauthorized) {
  auto client = std::make_unique<MockApiClient>();
  auto result = AuthorizationResult { .determination = "denied" };
  EXPECT_CALL(*client, authorize(_)).WillOnce(Return(result));
  Authorizer authorizer(std::move(client));

  Request req;
  auto actual = authorizer.authorize(req);
  EXPECT_THAT(actual["determination"], "denied");
}

TEST(AuthorizerTest, JoinsPublicCollections) {
  auto client = std::make_unique<MockApiClient>();
  auto result = AuthorizationResult { .public_collections = {"pub1", "pub2"} };
  EXPECT_CALL(*client, authorize(_)).WillOnce(Return(result));
  Authorizer authorizer(std::move(client));

  Request req;
  auto actual = authorizer.authorize(req);
  EXPECT_THAT(actual["public_collections"], "pub1:pub2");
}

TEST(AuthorizerTest, JoinsAuthorizedCollections) {
  auto client = std::make_unique<MockApiClient>();
  auto result = AuthorizationResult { .authorized_collections = {"auth1", "auth2"} };
  EXPECT_CALL(*client, authorize(_)).WillOnce(Return(result));
  Authorizer authorizer(std::move(client));

  Request req;
  auto actual = authorizer.authorize(req);
  EXPECT_THAT(actual["authorized_collections"], "auth1:auth2");
}
