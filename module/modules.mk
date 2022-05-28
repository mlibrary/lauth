mod_lauth.la: mod_lauth.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_lauth.lo
DISTCLEAN_TARGETS = modules.mk
shared =  mod_lauth.la
