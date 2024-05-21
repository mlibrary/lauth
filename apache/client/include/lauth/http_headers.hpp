#ifndef __LAUTH_HTTP_HEADERS_HPP__
#define __LAUTH_HTTP_HEADERS_HPP__

#include <map>
#include <string>

namespace mlibrary::lauth {
  namespace detail {
    // https://github.com/yhirose/cpp-httplib/blob/3b6597bba913d51161383657829b7e644e59c006/httplib.h#L315
    struct ci {
      bool operator()(const std::string &s1, const std::string &s2) const {
        return std::lexicographical_compare(s1.begin(), s1.end(), s2.begin(),
                                            s2.end(),
                                            [](unsigned char c1, unsigned char c2) {
                                              return ::tolower(c1) < ::tolower(c2);
                                            });
      }
    };
  }
  using HttpHeaders = std::multimap<std::string, std::string, detail::ci>;
}

#endif // __LAUTH_HTTP_HEADERS_HPP__
