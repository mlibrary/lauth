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
    if (!r->user) {
        return AUTHZ_DENIED_NO_USER;
    } else if (!strcmp("lauth-denied", r->user)) {
        return AUTHZ_DENIED;
    }

    return AUTHZ_GRANTED;
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


