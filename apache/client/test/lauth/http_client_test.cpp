#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include <httplib.h>

#include "mocks.hpp"

#include "lauth/http_client.hpp"
#include "lauth/http_params.hpp"
#include "lauth/request.hpp"

#include <string>
#include <cstdlib>

using testing::_;
using testing::Eq;
using testing::IsTrue;

using namespace mlibrary::lauth;

const std::string LOCAL_MOCK_API_URL = "http://localhost:9000";

const static std::string& MOCK_API_URL() {
    static std::string url;
    if (url.empty()) {
        if (const char *env_url = std::getenv("LAUTH_TEST_API_URL"))
            url = std::string(env_url);
        else
            url = LOCAL_MOCK_API_URL;
    }
    return url;
}

TEST(HttpClient, uses_mock_server) {
  HttpClient client(MOCK_API_URL());

  auto response = client.get("/");
  ASSERT_THAT(response.has_value(), IsTrue()) << "Mock server does not appear responsive at "
    << MOCK_API_URL() << ". Is it running? Have you set LAUTH_TEST_API_URL correctly?";
}

TEST(HttpClient, get_request_returns_body) {
  HttpClient client(MOCK_API_URL());

  auto response = client.get("/");
  EXPECT_THAT(response, Eq("Root"));
}

TEST(HttpClient, get_request_with_path_returns_body) {
  HttpClient client(MOCK_API_URL());

  auto response = client.get("/ping");
  EXPECT_THAT(response, "pong");
}

TEST(HttpClient, GetRequestWithOneParameterEncodesIt) {
  HttpClient client(MOCK_API_URL());

  HttpParams params;
  params.emplace("foo", "bar");
  auto response = client.get("/echo", params);

  EXPECT_THAT(*response, Eq(R"({"foo":"bar"})"));
}

TEST(HttpClient, GetRequestWithMultipleParametersEncodesThem) {
  HttpClient client(MOCK_API_URL());

  HttpParams params;
  params.emplace("foo", "bar");
  params.emplace("something", "else");
  auto response = client.get("/echo", params);

  EXPECT_THAT(*response, Eq(R"({"foo":"bar","something":"else"})"));
}
