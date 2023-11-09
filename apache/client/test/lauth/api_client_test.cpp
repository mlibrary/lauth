#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "mocks.hpp"

using ::testing::_;
using ::testing::Return;

#include "lauth/api_client.hpp"
#include "lauth/request.hpp"

using namespace mlibrary::lauth;

TEST(ApiClientTest, allowed_by_mock) {
  auto client = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*client, isAllowed(_)).WillOnce(Return(true));
  ApiClient api_client(std::move(client));

  Request req {};

  auto allowed = api_client.isAllowed(req);

  EXPECT_THAT(allowed, true);
}

TEST(ApiClientTest, denied_by_mock) {
  auto client = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*client, isAllowed(_)).WillOnce(Return(false));
  ApiClient api_client(std::move(client));

  Request req {};

  auto allowed = api_client.isAllowed(req);

  EXPECT_THAT(allowed, false);
}

TEST(ApiClientTest, a_request_with_no_user_is_denied) {
  ApiClient client;
  Request request;

  bool result = client.isAllowed(request);
  EXPECT_THAT(result, false);
}


TEST(ApiClientTest, a_request_with_authorized_user_is_allowed) {
  ApiClient client;
  Request request;

  request.user = "authorized";
  bool result = client.isAllowed(request);
  EXPECT_THAT(result, true);
}

TEST(ApiClientTest, a_request_with_unauthorized_user_is_denied) {
  ApiClient client;
  Request request;

  request.user = "unauthorized";
  bool result = client.isAllowed(request);
  EXPECT_THAT(result, false);
}
