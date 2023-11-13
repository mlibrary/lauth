#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "mocks.hpp"

using ::testing::_;
using ::testing::AnyNumber;
using ::testing::Return;

#include "lauth/api_client.hpp"
#include "lauth/request.hpp"

using namespace mlibrary::lauth;

TEST(ApiClient, HttpRequestByApiClientIsCorrect) {
  auto client = std::make_unique<MockHttpClient>();

  Request req {
    .ip = "127.0.0.1",
    .uri = "/resource",
    .user = "username",
  };

  HttpParams params {
      {"uri", req.uri},
      {"user", req.user}
  };

  auto body = R"({"any":"thing"})";

  EXPECT_CALL(*client, get("/authorized", params)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  api_client.authorized(req);
}

TEST(ApiClient, ResponseByApiClientIsCorrect) {
  auto client = std::make_unique<MockHttpClient>();

  auto body = R"({"result":"allowed"})";

  EXPECT_CALL(*client, get(_, _)).WillOnce(Return(body));
  ApiClient api_client(std::move(client));

  auto allowed = api_client.authorized(Request());
  EXPECT_THAT(allowed, true);
}

TEST(ApiClient, RequestByUnknownUserIsDenied) {
  GTEST_SKIP() << "This is passing for the wrong reason and GMock is giving "
               << "a warning because we have not set any expectations. "
               << "There is an uninteresting/unexpected call to the HttpClient "
               << "to get '/users//is_allowed', which should be rejected "
               << "before the HTTP request or expressed differently (possibly "
               << "with query params).";
  auto http_client = std::make_unique<MockHttpClient>();
  ApiClient client(std::move(http_client));
  Request request;

  bool result = client.authorized(request);
  EXPECT_THAT(result, false);
}

TEST(ApiClient, UsesTheSuppliedApiUrl) {
  GTEST_SKIP() << "Skipping test that ApiClient makes an HttpClient for the "
               << "correct URL... pushing everything back to config and likely "
               << "a factory/builder rather than concrete class dependency.";
  ApiClient client("http://api.invalid");
}
