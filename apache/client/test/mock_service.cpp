#include <httplib.h>

int main(int argc, char **argv) {
  using namespace httplib;

  int port;
  const std::string address = "0.0.0.0";
  Server server;

  if (argc == 2) {
    port = std::atoi(argv[1]);
    server.bind_to_port(address, port);
  } else {
    port = server.bind_to_any_port(address);
  }

  server.Get("/", [](const Request &, Response &res) {
    std::cout << "GET /" << std::endl;
    res.set_content("Root", "text/plain");
  });

  server.Get("/ping", [](const Request &, Response &res) {
    std::cout << "GET /ping" << std::endl;
    res.set_content("pong", "text/plain");
  });

  server.Get("/users/authorized/is_allowed", [](const Request &, Response &res) {
    std::cout << "GET /users/authorized/is_allowed" << std::endl;
    res.set_content("yes", "text/plain");
  });

  server.Get("/users/unauthorized/is_allowed", [](const Request &, Response &res) {
    std::cout << "GET /users/unauthorized/is_allowed" << std::endl;
    res.set_content("no", "text/plain");
  });

  server.Get("/stop", [&](const Request &, Response &res) {
    res.set_content("Shutting down server...", "text/plain");
    server.stop();
  });

  server.Get("/users/:id/is_allowed", [](const Request &req, Response &res) {
    auto user_id = req.path_params.at("id");
    std::cout << "GET /users/:id/is_allowed -- "
              << "binding :id as '" << user_id << "'" << std::endl;
    res.set_content("no", "text/plain");
  });

  std::cout << "Listening on http://" << address << ":" << port << std::endl;
  std::cout << "Stop URL: http://" << address << ":" << port << "/stop"
            << std::endl;
  server.listen_after_bind();
  std::cout << "Server has stopped... Bye!" << std::endl;
  return 0;
}
