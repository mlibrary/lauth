#include <gtest/gtest.h>
#include <gmock/gmock.h>

using testing::_;

#include <httplib.h>

#include "lauth/http_client.hpp"
#include "lauth/request.hpp"

using namespace mlibrary::lauth;

TEST(HttpClientTest, mock_service_response_with_is_allowed) {
  std::string host = "";
  uint16_t port = 0;
  HttpClient client(host, port);

  Request req;
  req.user = "authorized";

  bool result = client.isAllowed(req);
  EXPECT_THAT(result, true);
}

TEST(HttpClientTest, mock_service_response_with_is_not_allowed) {
  std::string host = "";
  uint16_t port = 0;
  HttpClient client(host, port);

  Request req;
  req.user = "authorized";

  bool result = client.isAllowed(req);
  EXPECT_THAT(result, false);
}
