mod_authn_remoteuser.la: mod_authn_remoteuser.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_authn_remoteuser.lo
DISTCLEAN_TARGETS = modules.mk
shared =  mod_authn_remoteuser.la
