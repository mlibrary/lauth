#include "httpd.h"
#include "http_config.h"
#include "http_protocol.h"
#include "http_request.h"
#include "http_log.h"
#include "ap_config.h"
#include "ap_provider.h"

#include "mod_auth.h"

#include <lauth/authorizer.hpp>

#include <string>
#include <map>

using namespace mlibrary::lauth;

extern "C" {

    void lauth_register_hooks(apr_pool_t *p);

    APLOG_USE_MODULE(lauth);
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

static authz_status lauth_check_authorization(request_rec *r,
                                                  const char *require_line,
                                                  const void *parsed_require_line)
{
    if (!r->ap_auth_type) return AUTHZ_DENIED_NO_USER;

    Request req;
    std::string handler = r->handler ? std::string(r->handler) : "";
    if (handler.substr(0, handler.find(":")) == "proxy-server") {
      req = Request {
        .ip = r->useragent_ip ? std::string(r->useragent_ip) : "",
        .uri = r->uri ? std::string(r->uri) : "",
        .user = r->user ? std::string(r->user) : ""
      };
    } else {
      req  = Request {
        .ip = r->useragent_ip ? std::string(r->useragent_ip) : "",
        .uri = r->filename,
        .user = r->user ? std::string(r->user) : ""
      };
    }

    std::map<std::string, std::string> result =
      Authorizer("http://app.lauth.local:2300").authorize(req);

    apr_table_set(r->subprocess_env, "PUBLIC_COLL", result["public_collections"].c_str());
    apr_table_set(r->subprocess_env, "AUTHZD_COLL", result["authorized_collections"].c_str());

    return result["determination"] == "allowed" ? AUTHZ_GRANTED : AUTHZ_DENIED;
}

static const authz_provider authz_lauth_provider =
{
    &lauth_check_authorization,
    NULL
};

void lauth_register_hooks(apr_pool_t *p)
{
    ap_register_auth_provider(p, AUTHZ_PROVIDER_GROUP, "lauth",
                          AUTHZ_PROVIDER_VERSION,
                          &authz_lauth_provider, AP_AUTH_INTERNAL_PER_CONF);
}


