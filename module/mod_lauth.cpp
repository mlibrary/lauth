/* 
**  mod_lauth.c -- Apache sample lauth module
**  [Autogenerated via ``apxs -n lauth -g'']
**
**  To play with this sample module first compile it into a
**  DSO file and install it into Apache's modules directory 
**  by running:
**
**    $ apxs -c -i mod_lauth.c
**
**  Then activate it in Apache's httpd.conf file for instance
**  for the URL /lauth in as follows:
**
**    #   httpd.conf
**    LoadModule lauth_module modules/mod_lauth.so
**    <Location /lauth>
**    SetHandler lauth
**    </Location>
**
**  Then after restarting Apache via
**
**    $ apachectl restart
**
**  you immediately can request the URL /lauth and watch for the
**  output of this module. This can be achieved for instance via:
**
**    $ lynx -mime_header http://localhost/lauth 
**
**  The output should be similar to the following one:
**
**    HTTP/1.1 200 OK
**    Date: Tue, 31 Mar 1998 14:42:22 GMT
**    Server: Apache/1.3.4 (Unix)
**    Connection: close
**    Content-Type: text/html
**  
**    The sample page from mod_lauth.c
*/ 

#include "httpd.h"
#include "http_config.h"
#include "http_protocol.h"
#include "ap_config.h"

#define CPPHTTPLIB_OPENSSL_SUPPORT
#include <httplib.h>
#include <json.hpp>

using json = nlohmann::json;

extern "C" {
    void lauth_register_hooks(apr_pool_t *p);

    /* Dispatch list for API hooks */
    module AP_MODULE_DECLARE_DATA lauth_module = {
        STANDARD20_MODULE_STUFF, 
        NULL,                  /* create per-dir    config structures */
        NULL,                  /* merge  per-dir    config structures */
        NULL,                  /* create per-server config structures */
        NULL,                  /* merge  per-server config structures */
        NULL,                  /* table of config file commands       */
        lauth_register_hooks  /* register hooks                      */
    };
};

/* The sample content handler */
int lauth_handler(request_rec *r)
{
    if (strcmp(r->handler, "lauth")) {
        return DECLINED;
    }
    r->content_type = "text/html";      

    json j = {
        {"foo", "bar"},
        {"baz", "quux"},
        {"val", 12}
    };

    httplib::Client http("http://api.lauth.local:9292");

    auto response = http.Get("/users/root");
    json library = json::parse(response->body);

    if (!r->header_only) {
        ap_rprintf(r, "Literal json object: <pre><code>%s</pre></code><br/>", j.dump().c_str());
        ap_rprintf(r, "API response, pretty-printed: <pre><code>%s</pre></code>", library.dump(4).c_str());
    }
    return OK;
}

void lauth_register_hooks(apr_pool_t *p)
{
    ap_hook_handler(lauth_handler, NULL, NULL, APR_HOOK_MIDDLE);
}


