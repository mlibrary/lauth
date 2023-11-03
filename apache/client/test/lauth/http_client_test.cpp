#include <gtest/gtest.h>
#include <gmock/gmock.h>

using testing::_;

#include "lauth/http_client.hpp"
#include "lauth/request.hpp"

using namespace mlibrary::lauth;

TEST(HttpClientTest, a_request_with_authorized_user_is_allowed) {
  HttpClient client;
  Request request;

  request.user = "authorized";
  bool result = client.isAllowed(request);
  EXPECT_THAT(result, true);
}
