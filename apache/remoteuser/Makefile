##
##  Makefile -- Build procedure for sample authn_remoteuser Apache module
##  Autogenerated via ``apxs -g''.
##

builddir=.
top_srcdir=/usr/share/apache2
top_builddir=/usr/share/apache2
include /usr/share/apache2/build/special.mk

#   the used tools
APACHECTL=apachectl

#   additional defines, includes and libraries
#DEFS=-Dmy_define=my_value
#INCLUDES=-I/usr/local/include
#LIBS=

#   the default target
all: local-shared-build

install: install-modules-yes

#   cleanup
clean:
	-rm -f mod_authn_remoteuser.o mod_authn_remoteuser.lo mod_authn_remoteuser.slo mod_authn_remoteuser.la

#   install and activate shared object by reloading Apache to
#   force a reload of the shared object file
reload: install restart

#   the general Apache start/restart/stop
#   procedures
start:
	$(APACHECTL) start
restart:
	$(APACHECTL) restart
stop:
	$(APACHECTL) stop

