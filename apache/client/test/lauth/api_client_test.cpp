#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "mocks.hpp"

using ::testing::_;
using ::testing::Return;

#include "lauth/api_client.hpp"
#include "lauth/request.hpp"

using namespace mlibrary::lauth;

TEST(ApiClient, allowed_by_mock_http_client) {
  auto client = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*client, get("/users/authorized/is_allowed")).WillOnce(Return("yes"));
  ApiClient api_client(std::move(client));

  Request req {
    .user = "authorized",
  };

  auto allowed = api_client.isAllowed(req);

  EXPECT_THAT(allowed, true);
}

TEST(ApiClient, denied_by_mock_http_client) {
  auto client = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*client, get("/users/unauthorized/is_allowed")).WillOnce(Return("no"));
  ApiClient api_client(std::move(client));

  Request req {
    .user = "unauthorized",
  };

  auto allowed = api_client.isAllowed(req);

  EXPECT_THAT(allowed, false);
}

TEST(ApiClient, a_request_with_no_user_is_denied) {
  ApiClient client("http://localhost:9000");
  Request request;

  bool result = client.isAllowed(request);
  EXPECT_THAT(result, false);
}


TEST(ApiClient, a_request_with_authorized_user_is_allowed) {
  ApiClient client("http://localhost:9000");
  Request request;

  request.user = "authorized";
  bool result = client.isAllowed(request);
  EXPECT_THAT(result, true);
}

TEST(ApiClient, a_request_with_unauthorized_user_is_denied) {
  ApiClient client("http://localhost:9000");
  Request request;

  request.user = "unauthorized";
  bool result = client.isAllowed(request);
  EXPECT_THAT(result, false);
}
