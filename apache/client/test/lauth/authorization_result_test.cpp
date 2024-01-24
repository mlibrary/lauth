#include "lauth/authorization_result.hpp"

#include <string>
#include <vector>

#include <gtest/gtest.h>
#include <gmock/gmock.h>

#include "lauth/json.hpp"
#include "lauth/json_conversions.hpp"

using namespace mlibrary::lauth;

TEST(AuthorizationResultTest, FromJson) {
  std::string stringBody =
    R"({"determination":"allowed",)"
    R"("public_collections":["pub1","pub2"],)"
    R"("authorized_collections":["auth1","auth2"]})";
  json jsonBody = json::parse(stringBody);
  AuthorizationResult result = jsonBody.template get<AuthorizationResult>();

  EXPECT_THAT(result.determination, "allowed");
  EXPECT_THAT(result.public_collections, testing::ElementsAre("pub1", "pub2"));
  EXPECT_THAT(result.authorized_collections, testing::ElementsAre("auth1", "auth2"));
}


TEST(AuthorizationResultTest, ToJson) {
  std::vector<std::string> public_collections = {"pub1", "pub2"};
  std::vector<std::string> authorized_collections = {"auth1", "auth1"};
  AuthorizationResult result {
    .determination = "allowed",
    .public_collections = public_collections,
    .authorized_collections = authorized_collections
  };
  json j = result; // magic

  EXPECT_THAT(j["determination"], "allowed");
}
