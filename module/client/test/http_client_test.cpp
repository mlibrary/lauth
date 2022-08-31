#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include <json.hpp>

#include "lauth/http_client.h"

using json = nlohmann::json;
using namespace mlibrary::lauth;

TEST(HttpClientTest, GetsUrl) {
    HttpClient client("https://api.github.com");

    auto body = client.getBody("/orgs/mlibrary");
    json mlibrary = json::parse(body);

    EXPECT_THAT(mlibrary["name"], "University of Michigan Library");
}
