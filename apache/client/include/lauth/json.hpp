#ifndef __LAUTH_JSON_HPP__
#define __LAUTH_JSON_HPP__

#undef JSON_DIAGNOSTICS
#define JSON_DIAGNOSTICS 1
#include <nlohmann/json.hpp>

namespace mlibrary::lauth
{
    using json = nlohmann::json;
}

#endif // __LAUTH_JSON_HPP__
