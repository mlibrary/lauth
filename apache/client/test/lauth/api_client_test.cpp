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
      {"uri", req.uri},
      {"user", req.user}
  };

  auto body = R"({"any":"thing"})";

  EXPECT_CALL(*client, get("/authorized", params)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  api_client.authorized(req);
}

TEST(ApiClient, ResponseOfAllowedReturnsTrue) {
  auto client = std::make_unique<MockHttpClient>();

  auto body = R"({"result":"allowed"})";

  EXPECT_CALL(*client, get(_, _)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  auto allowed = api_client.authorized(Request());
  EXPECT_THAT(allowed, true);
}

TEST(ApiClient, ResponseOfDeniedReturnsFalse) {
  auto client = std::make_unique<MockHttpClient>();

  auto body = R"({"result":"denied"})";

  EXPECT_CALL(*client, get(_, _)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  auto authorized = api_client.authorize(Request());
  EXPECT_THAT(authorized.determination, "denied");
}
