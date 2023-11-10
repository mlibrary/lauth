#include <gtest/gtest.h>
#include <gmock/gmock.h>

using testing::_;
using testing::Eq;
using testing::IsTrue;

#include <httplib.h>

#include "lauth/http_client.hpp"
#include "lauth/request.hpp"

#include <cstdlib>

using namespace mlibrary::lauth;

const std::string LOCAL_API_URL = "http://localhost:9000";

const std::string TEST_API() {
  if (const char *env_url = std::getenv("LAUTH_TEST_API_URL"))
    return std::string(env_url);
  else
    return LOCAL_API_URL;
}

TEST(HttpClient, tests_require_mock_api) {
  HttpClient client(TEST_API());

  auto response = client.get("/");
  ASSERT_THAT(response.has_value(), IsTrue()) << "Test server does not appear responsive at "
    << TEST_API() << ". Is it running? Have you set LAUTH_TEST_API_URL correctly?";
}

TEST(HttpClient, get_request_returns_body) {
  HttpClient client(TEST_API());

  auto response = client.get("/");
  EXPECT_THAT(response, Eq("Root"));
}

TEST(HttpClient, get_request_with_path_returns_body) {
  HttpClient client(TEST_API());

  auto response = client.get("/ping");
  EXPECT_THAT(response, "pong");
}
