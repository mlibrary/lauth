mod_lauth.la: mod_lauth.slo lauth-client.slo
	$(SH_LINK) -rpath $(libexecdir) -module -avoid-version  mod_lauth.lo lauth-client.lo
DISTCLEAN_TARGETS = modules.mk
shared =  mod_lauth.la

lauth-client.la: lauth-client.slo
lauth-client.lo: client/lauth/*.cpp
	$(LIBTOOL) --mode=compile $(CXX_COMPILE) $(LTCFLAGS) -c $< -o lauth-client.lo && touch $@
lauth-client.slo: client/lauth/*.cpp
	$(LIBTOOL) --mode=compile $(BASE_CXX) $(SHLTCFLAGS) -c $< -o lauth-client.lo && touch $@
