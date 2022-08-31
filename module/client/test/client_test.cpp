#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "lauth/client.h"
#include "lauth/http_client.h"

#include <json.hpp>
#include <httplib.h>

using namespace mlibrary::lauth;
using namespace mlibrary::lauth::v1;
using json = nlohmann::json;
using std::string;

using testing::Return;
using testing::_;

struct StubRawClient : public httplib::Client {
    StubRawClient() : httplib::Client("http://default.invalid") {}
};

class MockApi : public HttpClient {
    public:
    MockApi() : HttpClient(StubRawClient()) {}
    MOCK_METHOD(std::string, getBody, (const std::string&));
};

TEST(ClientTest, GetRootHasUserInfo) {
    std::string body = R"(
      {
        "userid": "root",
        "givenName": "Super",
        "surname": "User"
      }
    )";
    MockApi api;
    EXPECT_CALL(api, getBody(_)).WillRepeatedly(Return(body));

    Client client(&api);
    User user = client.getUser("root");

    EXPECT_EQ(user.userid, "root");
    EXPECT_EQ(user.givenName, "Super");
    EXPECT_EQ(user.surname, "User");
}
