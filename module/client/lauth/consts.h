#ifndef _LAUTH_CONSTS_H_
#define _LAUTH_CONSTS_H_

#include <map>
#include <string>

namespace mlibrary::lauth {
    enum class AuthenticationMethod { None, ClientAddress, Username, Any };
}

#endif
