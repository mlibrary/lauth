#include <exception>
#include <iostream>

#ifndef CPPHTTPLIB_OPENSSL_SUPPORT
#define CPPHTTPLIB_OPENSSL_SUPPORT 1
#endif

#include <httplib.h>

int main(int argc, char **argv) {
  if (argc < 2 || argc > 3) {
    std::cout << "Usage: http-check <host> [path]" << std::endl;
    return -1;
  }

  auto url = std::string(argv[1]);
  auto path = argc == 3 ? std::string(argv[2]) : "/";
  std::cout << "Requesting: '" << url << path << "'" << std::endl;

  httplib::Client cli(url);
  auto res = cli.Get(path);

  if (!res) {
    std::cout << "Request failed..." << std::endl;
    return -2;
  }

  std::cout << "Response Code: " << res->status << std::endl;
  std::cout << "-------------------" << std::endl;
  std::cout << res->body << std::endl;

  if (res->status != 200) {
    return -1;
  } else {
    return 0;
  }
}
