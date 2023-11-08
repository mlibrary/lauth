  
  #include <httplib.h>

  int main(int argc, char** argv)
  {
    using namespace httplib;

    Server micro_service;

    micro_service.Get("/user/:id/is_allowed", [](const Request& req, Response& res) {
    auto user_id = req.path_params.at("id");
    res.set_content("no", "text/plain");
    });

    micro_service.listen ("0.0.0.0", 8080);
  }