mod_lauth.la: liblauth-client.so mod_lauth.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_lauth.lo -Lclient/bazel-bin/lauth -llauth-client
DISTCLEAN_TARGETS = modules.mk
shared =  mod_lauth.la
