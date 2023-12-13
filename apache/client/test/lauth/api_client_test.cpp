#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "mocks.hpp"

using ::testing::_;
using ::testing::AnyNumber;
using ::testing::Return;

#include "lauth/api_client.hpp"
#include "lauth/request.hpp"
#include "lauth/authorization_result.hpp"

using namespace mlibrary::lauth;

TEST(ApiClient, HttpRequestByApiClientIsCorrect) {
  auto client = std::make_unique<MockHttpClient>();

  Request req {
    .ip = "127.0.0.1",
    .uri = "/resource",
    .user = "username",
  };

  HttpParams params {
      {"ip", req.ip},
      {"uri", req.uri},
      {"user", req.user}
  };

  auto body = R"({"determination":"allowed"})";

  EXPECT_CALL(*client, get("/authorized", params)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  api_client.authorize(req);
}

TEST(ApiClient, DeterminationAllowedReturnsTrue) {
  auto client = std::make_unique<MockHttpClient>();
  auto body = R"({"determination":"allowed"})";

  EXPECT_CALL(*client, get(_, _)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  auto result = api_client.authorize(Request());
  EXPECT_THAT(result.determination, "allowed");
}

TEST(ApiClient, DeterminationDeniedReturnsFalse) {
  auto client = std::make_unique<MockHttpClient>();
  auto body = R"({"determination":"denied"})";

  EXPECT_CALL(*client, get(_, _)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  auto result = api_client.authorize(Request());
  EXPECT_THAT(result.determination, "denied");
}

TEST(ApiClient, MismatchedJsonReturnsFalse) {
  auto client = std::make_unique<MockHttpClient>();
  auto body = R"({"should_ignore_this_key":"allowed"})";

  EXPECT_CALL(*client, get(_, _)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  auto result = api_client.authorize(Request());
  EXPECT_THAT(result.determination, "denied");
}

TEST(ApiClient, MalformedJsonReturnsFalse) {
  auto client = std::make_unique<MockHttpClient>();
  auto body = R"({"should_ignore_this_key":"allowed",)";

  EXPECT_CALL(*client, get(_, _)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  auto result = api_client.authorize(Request());
  EXPECT_THAT(result.determination, "denied");
}

TEST(ApiClient, EmptyBodyReturnsFalse) {
  auto client = std::make_unique<MockHttpClient>();
  auto body = "";

  EXPECT_CALL(*client, get(_, _)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  auto result = api_client.authorize(Request());
  EXPECT_THAT(result.determination, "denied");
}
