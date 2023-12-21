#include "assert.h"
#include "httpd.h"
#include "http_config.h"
#include "http_core.h"
#include "http_protocol.h"
#include "http_request.h"
#include "http_log.h"
#include "ap_config.h"
#include "ap_provider.h"
#include "apr_strings.h"
#define APR_WANT_STRFUNC
#include "apr_want.h"

#include "mod_auth.h"

static const char* AUTH_TYPE_REMOTE_USER = "RemoteUser";

APLOG_USE_MODULE(authn_remoteuser);

typedef struct remoteuser_config_struct {
  const char* header;
  const char* anonymous_username;
} remoteuser_config;

static void *create_remoteuser_config(apr_pool_t *p) {
  remoteuser_config *config = (remoteuser_config *) apr_pcalloc(p, sizeof(*config));
  config->header = NULL;
  config->anonymous_username = "";

  return config;
}

static void *create_remoteuser_server_config(apr_pool_t *p, server_rec *_) {
  return create_remoteuser_config(p);
}

static void *create_remoteuser_dir_config(apr_pool_t *p, char *_) {
  return create_remoteuser_config(p);
}

static const char *set_header(cmd_parms *cmd, void *config, const char *header) {
  if (!*header) {
    return "Remote user header cannot be empty";
  }

  remoteuser_config *conf = (remoteuser_config *) config;
  conf->header = apr_pstrdup(cmd->pool, header);
  return NULL;
}

static const char *set_anonymous_user(cmd_parms *cmd, void *config, const char *user) {
  remoteuser_config *conf = (remoteuser_config *) config;
  conf->anonymous_username = apr_pstrdup(cmd->pool, user);
  return NULL;
}

static const command_rec remoteuser_cmds[] = {
  AP_INIT_TAKE1("RemoteUserHeader", set_header, NULL, RSRC_CONF|ACCESS_CONF|OR_AUTHCFG,
      "The header to use for setting the authenticated user (REMOTE_USER)"),
  AP_INIT_TAKE1("RemoteUserAnonymousUsername", set_anonymous_user, NULL, RSRC_CONF|ACCESS_CONF|OR_AUTHCFG,
      "The username to use for anonymous users, defaults to the empty string"),
  {NULL}
};

static int configured_for_request(request_rec *r) {
  const char *current_auth = ap_auth_type(r);
  return (current_auth && !strcasecmp(current_auth, AUTH_TYPE_REMOTE_USER));
}

static int check_header(request_rec *r) {
  if (!configured_for_request(r)) {
    return DECLINED;
  }

  remoteuser_config *conf = (remoteuser_config *) ap_get_module_config(r->per_dir_config, &authn_remoteuser_module);

  if (!conf->header) {
    ap_log_rerror(APLOG_MARK, APLOG_ERR, 0, r, "Configured for RemoteUser authentication, but no header is configured; set RemoteUserHeader for the server, directory, or location.");
    return HTTP_INTERNAL_SERVER_ERROR;
  }

  r->ap_auth_type = apr_pstrdup(r->pool, AUTH_TYPE_REMOTE_USER);

  char *remote_user = (char *) apr_table_get(r->headers_in, conf->header);
  if (remote_user) {
    ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r,
        "Header %s supplied; authenticating as user: \"%s\"", conf->header, remote_user);
    r->user = remote_user;
  } else {
    ap_log_rerror(APLOG_MARK, APLOG_DEBUG, 0, r,
        "Header %s absent/empty; authenticating as anonymous user: \"%s\"", conf->header, conf->anonymous_username);
    r->user = conf->anonymous_username;
  }

  return OK;
}

static void remoteuser_register_hooks(apr_pool_t *p)
{
    ap_hook_check_authn(&check_header, NULL, NULL,
        APR_HOOK_MIDDLE, AP_AUTH_INTERNAL_PER_CONF);
}

module AP_MODULE_DECLARE_DATA authn_remoteuser_module = {
    STANDARD20_MODULE_STUFF,
    create_remoteuser_dir_config,  /* create per-dir    config structures */
    NULL,                  /* merge  per-dir    config structures */
    NULL, //create_remoteuser_server_config,     /* create per-server config structures */
    NULL,                  /* merge  per-server config structures */
    remoteuser_cmds,       /* table of config file commands       */
    remoteuser_register_hooks  /* register hooks                      */
};
