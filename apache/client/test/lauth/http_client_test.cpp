#include <gtest/gtest.h>
#include <gmock/gmock.h>

using testing::_;

#include <httplib.h>

#include "lauth/http_client.hpp"
#include "lauth/request.hpp"

using namespace mlibrary::lauth;

const std::string api_url = "http://localhost:9000";

TEST(HttpClientTest, mock_service_response) {
  HttpClient client(api_url);

  std::string response = client.get("/");
  EXPECT_THAT(response, "Root");
}

