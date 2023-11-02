#include <gtest/gtest.h>
#include <gmock/gmock.h>

using testing::_;

#include "lauth/api_client.hpp"
#include "lauth/request.hpp"

using namespace mlibrary::lauth;

TEST(ApiClient, a_request_with_no_user_is_denied) {
  ApiClient client;
  Request request;

  bool result = client.isAllowed(request);
  EXPECT_THAT(result, false);
}


TEST(ApiClient, a_request_with_authorized_user_is_allowed) {
  ApiClient client;
  Request request;

  request.user = "authorized";
  bool result = client.isAllowed(request);
  EXPECT_THAT(result, true);
}

// TEST(ApiClient, a_request_with_unauthorized_user_is_denied) {
//   ApiClient client;
//   Request request;

//   request.user = "unauthorized";
//   bool result = client.isAllowed(request);
//   EXPECT_THAT(result, false);
// }
