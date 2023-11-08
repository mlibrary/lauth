#include <gtest/gtest.h>
#include <gmock/gmock.h>

using testing::_;

#include <httplib.h>

#include "lauth/http_client.hpp"
#include "lauth/request.hpp"

using namespace mlibrary::lauth;

const std::string api_url = "http://localhost:9000";

TEST(HttpClient, get_request_returns_body) {
  HttpClient client(api_url);

  std::string response = client.get("/");
  EXPECT_THAT(response, "Root");
}

TEST(HttpClient, get_request_with_path_returns_body) {
  HttpClient client(api_url);

  std::string response = client.get("/ping");
  EXPECT_THAT(response, "pong");
}
