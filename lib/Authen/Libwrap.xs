/*
 * $Id$
 */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <tcpd.h>
#include <syslog.h>

int allow_severity = LOG_INFO;
int deny_severity = LOG_NOTICE;

MODULE = Authen::Libwrap			PACKAGE = Authen::Libwrap

int
_hosts_ctl(daemon, client_name, client_addr, client_user)
	char *daemon
	char *client_name
	char *client_addr
	char *client_user
    CODE:
        {
            if( SvTRUE( get_sv( "Authen::Libwrap::DEBUG", FALSE) ) ) {
                PerlIO_printf(PerlIO_stderr(), "hosts_ctl: %s, %s, %s, %s\n",
                              daemon, client_name, client_addr, client_user);
            }
            RETVAL = hosts_ctl(daemon, client_name, client_addr, client_user);
        }
    OUTPUT:
        RETVAL
    POSTCALL:
        if( 0 == RETVAL ) {
            XSRETURN_UNDEF;
        }

/* EOF */
