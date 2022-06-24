#include <gtest/gtest.h>
#include "lauth/client.h"

using namespace mlibrary::lauth::v1;
using std::string;

TEST(ClientTest, GetRootHasUserInfo) {
    Client client("http://api.lauth.local:9292");
    User user = client.getUser("root");
    EXPECT_EQ(user.userid, "root");
    EXPECT_EQ(user.givenName, "Super");
    EXPECT_EQ(user.surname, "User");
}
