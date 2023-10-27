#include <gtest/gtest.h>
#include <gmock/gmock.h>
#include "lauth/authorizer.h"
#include "lauth/client.h"
#include "lauth/request_info.h"
#include "test/mocks.h"

#include <memory>
#include <string>

using namespace mlibrary::lauth;
using namespace mlibrary::lauth::v1;

using std::string;

using testing::IsFalse;
using testing::IsTrue;
using testing::Return;
using testing::_;

/* TEST(AuthorizerTest, figuringitout) { */
/*     RequestInfo req { */
/*         .uri = "/foo", */
/*         .filename = "/bonk.php", */
/*     }; */
/*     Authorizer lauth; */
/*     bool authorized = lauth.isAuthorized(); */

/*     EXPECT_THAT(authorized, IsFalse()); */
/* } */

/* TEST(AuthorizerTest, InjectsSystemCalls) { */
/*     auto system = std::make_unique<MockSystem>(); */
/*     EXPECT_CALL(*system, getHostname()).WillRepeatedly(Return("lauth.host")); */

/*     Authorizer lauth(std::move(system)); */
/*     EXPECT_THAT(lauth.getHostname(), "lauth.host"); */
/* } */

/* TEST(AuthorizerTest, EmptyRequestInfoUnauthorized) { */
/*     auto system = std::make_unique<MockSystem>(); */
/*     auto client = std::make_unique<MockClient>(); */
/*     EXPECT_CALL(*system, getHostname()).WillRepeatedly(Return("lauth.host")); */

/*     Authorizer lauth(std::move(system), std::move(client)); */
/*     RequestInfo req; */
/*     EXPECT_THAT(lauth.isAuthorized(req), false); */
/* } */

TEST(AuthorizerTest, UnregisteredUrlAlwaysAuthorized) {
    auto system = std::make_unique<MockSystem>();
    auto client = std::make_unique<MockClient>();
    EXPECT_CALL(*system, getHostname()).WillRepeatedly(Return("lauth.host"));
    EXPECT_CALL(*client, findCollection).WillOnce(Return(std::nullopt));
    Authorizer lauth(std::move(system), std::move(client));
    RequestInfo req {
        .uri = "/unregistered/"
    };

    auto result = lauth.process(req);
    EXPECT_THAT(result.status, STATUS_ALLOWED);
}

TEST(AuthorizerTest, ProtectedWithNoUsernameIsUnauthorized) {
    auto system = std::make_unique<MockSystem>();
    auto client = std::make_unique<MockClient>();
    auto coll = std::make_optional(Collection { .id = "resource", .authenticationMethod = "username" });
    EXPECT_CALL(*system, getHostname()).WillRepeatedly(Return("lauth.host"));
    EXPECT_CALL(*client, findCollection).WillRepeatedly(Return(coll));
    Authorizer lauth(std::move(system), std::move(client));
    RequestInfo req {
        .uri = "/lit-authn/"
    };

    auto result = lauth.process(req);
    EXPECT_THAT(result.status, STATUS_UNAUTHORIZED);
}


TEST(AuthorizerTest, ProtectedWithUnknownUsernameIsForbidden) {
    auto system = std::make_unique<MockSystem>();
    auto client = std::make_unique<MockClient>();
    auto coll = std::make_optional(Collection { .id = "resource", .authenticationMethod = "username" });
    EXPECT_CALL(*system, getHostname()).WillRepeatedly(Return("lauth.host"));
    EXPECT_CALL(*client, findCollection).WillRepeatedly(Return(coll));
    Authorizer lauth(std::move(system), std::move(client));
    RequestInfo req {
        .uri = "/lit-authn/",
        .username = "lauth-denied"
    };

    auto result = lauth.process(req);
    EXPECT_THAT(result.status, STATUS_FORBIDDEN);
}

TEST(AuthorizerTest, ProtectedWithAcceptedUsernameIsAllowed) {
    auto system = std::make_unique<MockSystem>();
    auto client = std::make_unique<MockClient>();
    auto coll = std::make_optional(Collection { .id = "resource", .authenticationMethod = "username" });
    EXPECT_CALL(*system, getHostname()).WillRepeatedly(Return("lauth.host"));
    EXPECT_CALL(*client, findCollection).WillRepeatedly(Return(coll));
    Authorizer lauth(std::move(system), std::move(client));
    RequestInfo req {
        .uri = "/lit-authn/",
        .username = "lauth-allowed"
    };

    auto result = lauth.process(req);
    EXPECT_THAT(result.status, STATUS_ALLOWED);
}
