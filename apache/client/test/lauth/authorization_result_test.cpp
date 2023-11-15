#include "lauth/authorization_result.hpp"

#include <string>

#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include <nlohmann/json.hpp>

#include "lauth/json_conversions.hpp"

using namespace mlibrary::lauth;
using json = nlohmann::json;

TEST(AuthorizationResultTest, FromJson) {
  std::string stringBody = R"({"determination":"allowed"})";
  json jsonBody = json::parse(stringBody);
  AuthorizationResult result = jsonBody.template get<AuthorizationResult>();

  EXPECT_THAT(result.determination, "allowed");
}


TEST(AuthorizationResultTest, ToJson) {
  AuthorizationResult result {
    .determination = "allowed"
  };
  json j = result; // magic

  EXPECT_THAT(j["determination"], "allowed");
}
