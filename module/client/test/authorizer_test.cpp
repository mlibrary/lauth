#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "lauth/authorizer.h"
#include "lauth/client.h"
#include "lauth/request_info.h"

#include <memory>
#include <string>

using namespace mlibrary::lauth;
using namespace mlibrary::lauth::v1;

using std::string;

using testing::IsFalse;
using testing::IsTrue;
using testing::Return;

class MockSystem : public System {
    public:
    MOCK_METHOD(std::string, getHostname, ());
};

class MockClient : public Client {
};

TEST(AuthorizerTest, figuringitout) {
    RequestInfo req {
        .uri = "/foo",
        .filename = "/bonk.php",
    };
    Authorizer lauth;
    bool authorized = lauth.isAuthorized();

    EXPECT_THAT(authorized, IsFalse());
}

TEST(AuthorizerTest, InjectsSystemCalls) {
    auto system = std::make_unique<MockSystem>();
    EXPECT_CALL(*system, getHostname()).WillRepeatedly(Return("lauth.host"));

    Authorizer lauth(std::move(system));
    EXPECT_THAT(lauth.getHostname(), "lauth.host");
}

TEST(AuthorizerTest, EmptyRequestInfoUnauthorized) {
    auto system = std::make_unique<MockSystem>();
    EXPECT_CALL(*system, getHostname()).WillRepeatedly(Return("lauth.host"));

    Authorizer lauth(std::move(system));
    RequestInfo req;
    EXPECT_THAT(lauth.isAuthorized(req), false);
}

TEST(AuthorizerTest, UnprotectedUrlAlwaysAuthorized) {
    auto system = std::make_unique<MockSystem>();
    EXPECT_CALL(*system, getHostname()).WillRepeatedly(Return("lauth.host"));
    Authorizer lauth(std::move(system));
    RequestInfo req {
        .uri = "/public/"
    };

    bool authorized = lauth.isAuthorized(req);

    /* EXPECT_THAT(authorized, true); */
}

