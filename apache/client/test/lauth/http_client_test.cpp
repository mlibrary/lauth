#include <gtest/gtest.h>
#include <gmock/gmock.h>

using testing::_;

#include <httplib.h>

#include "lauth/http_client.hpp"
#include "lauth/request.hpp"

using namespace mlibrary::lauth;

const std::string api_url = "http://localhost:9000";

TEST(HttpClientTest, mock_service_response_with_is_allowed) {
  HttpClient client(api_url);

  Request req;
  req.user = "authorized";

  bool result = client.isAllowed(req);
  EXPECT_THAT(result, true);
}

TEST(HttpClientTest, mock_service_response_with_is_not_allowed) {
  HttpClient client(api_url);

  Request req;
  req.user = "authorized";

  bool result = client.isAllowed(req);
  EXPECT_THAT(result, false);
}
