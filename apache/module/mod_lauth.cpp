#include "httpd.h"
#include "http_config.h"
#include "http_protocol.h"
#include "http_request.h"
#include "http_log.h"
#include "ap_config.h"
#include "ap_provider.h"
#include "apr_strings.h"

#include "mod_auth.h"

#include <lauth/authorizer.hpp>

#include <string>
#include <map>

using namespace mlibrary::lauth;

extern "C" {
    void *create_lauth_server_config(apr_pool_t *p, server_rec *_);
    const char *set_url(cmd_parms *cmd, void *cfg, const char* arg);
    const char *set_token(cmd_parms *cmd, void *cfg, const char* arg);

    static const command_rec lauth_cmds[] = {
        AP_INIT_TAKE1("LauthApiUrl", (cmd_func) set_url, NULL, RSRC_CONF|OR_AUTHCFG, "The URL to use for API."),
        AP_INIT_TAKE1("LauthApiToken", (cmd_func) set_token, NULL, RSRC_CONF|OR_AUTHCFG, "The token to use for API."),
        {NULL}};
    void lauth_register_hooks(apr_pool_t *p);

    APLOG_USE_MODULE(lauth);
    module AP_MODULE_DECLARE_DATA lauth_module = {
        STANDARD20_MODULE_STUFF,
        NULL,                       /* create per-dir    config structures */
        NULL,                       /* merge  per-dir    config structures */
        create_lauth_server_config, /* create per-server config structures */
        NULL,                       /* merge  per-server config structures */
        lauth_cmds,                 /* table of config file commands       */
        lauth_register_hooks        /* register hooks                      */
    };
};

typedef struct lauth_config_struct {
    const char *url;    /* URL to API */
    const char *token;  /* token for API */
} lauth_config;

void *create_lauth_server_config(apr_pool_t *p, server_rec *_) {
    lauth_config *config = (lauth_config *) apr_pcalloc(p, sizeof(*config));
    config->url = NULL;
    config->token = NULL;
    return (void*) config;
}

const char *set_url(cmd_parms *cmd, void *cfg, const char* arg)
{
    if(!*arg) {
        return "Lauth API URL cannot be empty";
    }

    lauth_config *config = (lauth_config *) ap_get_module_config(cmd->server->module_config, &lauth_module);
    config->url = apr_pstrdup(cmd->pool, arg);
    return NULL;
}

const char *set_token(cmd_parms *cmd, void *cfg, const char* arg)
{
    if(!*arg) {
        return "Lauth API Token cannot be empty";
    }

    lauth_config *config = (lauth_config *) ap_get_module_config(cmd->server->module_config, &lauth_module);
    config->token = apr_pstrdup(cmd->pool, arg);
    return NULL;
}

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

    lauth_config *config = (lauth_config *) ap_get_module_config(r->server->module_config, &lauth_module);
    std::map<std::string, std::string> result = Authorizer(config->url, config->token).authorize(req);

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
