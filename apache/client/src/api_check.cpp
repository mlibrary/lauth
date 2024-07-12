#include <exception>
#include <iostream>
#include <map>
#include <memory>

#include <lauth/authorizer.hpp>
#include <lauth/logging.hpp>

using namespace mlibrary::lauth;

int main(int argc, char **argv) {
  if (argc != 6) {
    std::cout << "Usage: api-check <host> <token> <uri> <ip> <username>" << std::endl;
    return -1;
  }

  auto host = std::string(argv[1]);
  auto token = std::string(argv[2]);
  auto uri = std::string(argv[3]);
  auto ip = std::string(argv[4]);
  auto user = std::string(argv[5]);
  std::cout << "Authorizing (via " << host << ") --  uri: " << uri << ", ip: " << ip << ", user: " << user << std::endl;

  Logger::set(std::make_shared<Logger>(std::make_unique<StdOut>()));
  auto auth = Authorizer(host, token);
  Request req = Request {
	  .ip = ip,
	  .uri = uri,
	  .user = user
  };

  auto result = auth.authorize(req);
  std::cout << "Authorizer worked... determination: " << result["determination"] << std::endl;
  return 0;
}
