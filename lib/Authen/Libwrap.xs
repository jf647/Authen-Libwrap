#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include <tcpd.h>
#include <syslog.h>

int allow_severity = LOG_INFO;
int deny_severity = LOG_NOTICE;

MODULE = Authen::Libwrap			PACKAGE = Authen::Libwrap

int
hosts_ctl( daemon, client_name, client_addr, client_user )
	char *daemon
	char *client_name
	char *client_addr
	char *client_user
	INIT:
        {
		int DEBUG = SvIV( perl_get_sv( "Authen::Libwrap::DEBUG", FALSE ) );

		if( DEBUG )
			fprintf( stderr, "hosts_ctl entry: hosts_ctl( %s, %s, %s, %s )\n",
				daemon, client_name, client_addr, client_user );
	}
