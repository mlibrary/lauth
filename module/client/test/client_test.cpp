#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "lauth/client.h"
#include "lauth/http_client.h"
#include "test/mocks.h"

#include <json.hpp>
#include <httplib.h>

using namespace mlibrary::lauth;
using namespace mlibrary::lauth::v1;
using json = nlohmann::json;
using std::string;

using testing::HasSubstr;
using testing::Return;
using testing::_;

TEST(ClientTest, GetRootHasUserInfo) {
    std::string body = R"(
      {
        "userid": "root",
        "givenName": "Super",
        "surname": "User"
      }
    )";
    auto api = std::make_unique<MockHttpClient>();
    EXPECT_CALL(*api, getBody(_)).WillOnce(Return(body));

    Client client(std::move(api));
    User user = client.getUser("root");

    EXPECT_EQ(user.userid, "root");
    EXPECT_EQ(user.givenName, "Super");
    EXPECT_EQ(user.surname, "User");
}

TEST(ClientTest, UnregisteredUrlPassesOnAuthentication) {
  std::string collInfo = R"(
    {
      "collection": null,
      "authenticationMethod": "none"
    }
  )";

  auto api = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*api, getBody(_)).WillOnce(Return(collInfo));
  Client client(std::move(api));

  auto method = client.getAuthenticationMethod("server.host", "/unregistered");
  ASSERT_THAT(method, AuthenticationMethod::None);
}

TEST(ClientTest, IpRestrictedUrlMethodIsClientAddress) {
  std::string collInfo = R"(
    {
      "collection": "some-coll",
      "authenticationMethod": "clientAddress"
    }
  )";
  auto api = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*api, getBody(_)).WillOnce(Return(collInfo));

  Client client(std::move(api));

  auto method = client.getAuthenticationMethod("server.host", "/lit-ip");
  EXPECT_THAT(method, AuthenticationMethod::ClientAddress);
}

TEST(ClientTest, UserRestrictedUrlMethodIsUsername) {
  std::string collInfo = R"(
    {
      "collection": "some-coll",
      "authenticationMethod": "username"
    }
  )";
  auto api = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*api, getBody(_)).WillOnce(Return(collInfo));

  Client client(std::move(api));

  auto method = client.getAuthenticationMethod("server.host", "/lit-authn");
  EXPECT_THAT(method, AuthenticationMethod::Username);
}

TEST(ClientTest, IpOrUserRestrictedUrlMethodIsAny) {
  std::string collInfo = R"(
    {
      "collection": "some-coll",
      "authenticationMethod": "any"
    }
  )";
  auto api = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*api, getBody(_)).WillOnce(Return(collInfo));

  Client client(std::move(api));

  auto method = client.getAuthenticationMethod("server.host", "/lit-authn-or-ip");
  EXPECT_THAT(method, AuthenticationMethod::Any);
}

TEST(ClientTest, AuthenticationMethodCallIncludesServer) {
  std::string collInfo = R"({"collection": null, "authenticationMethod": "none" })";
  auto api = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*api, getBody(HasSubstr("server=server.host"))).WillOnce(Return(collInfo));

  Client client(std::move(api));
  client.getAuthenticationMethod("server.host", "/resource");
}

TEST(ClientTest, AuthenticationMethodCallIncludesEscapedPath) {
  std::string collInfo = R"({"collection": null, "authenticationMethod": "none" })";
  auto api = std::make_unique<MockHttpClient>();
  EXPECT_CALL(*api, getBody(HasSubstr("uri=%2Fresource"))).WillOnce(Return(collInfo));

  Client client(std::move(api));
  client.getAuthenticationMethod("server.host", "/resource");
}

/* Given a collection configured for identity-based authentication */
/* When an anonymous user requests a URL in the collection */
/* Then the response is "unauthorized" */
/* And the user is redirected to login */
