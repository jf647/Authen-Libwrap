package Authen::Libwrap;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD $DEBUG);

use XSLoader;
require Exporter;
require AutoLoader;

use Carp;

@ISA = qw|Exporter AutoLoader|;

@EXPORT_OK = qw(
	hosts_ctl
	STRING_UNKNOWN
);

$VERSION = 0.11;

XSLoader::load 'Authen::Libwrap', $VERSION;

sub AUTOLOAD {

    my( $constname, $val );
    ($constname = $AUTOLOAD) =~ s/.*:://;
    $val = constant_NV( $constname, @_ ? $_[0] : 0 );
    if( $! != 0 ) {
	if( $! =~ /Invalid/ ) {
            $val = constant_SV( $constname, @_ ? $_[0] : 0 );
            if( $! ne "" ) {
                croak( "Your vendor has not defined Authen::Libwrap macro $constname" );
            } else {
                eval "sub $AUTOLOAD { '$val' }";
                goto &$AUTOLOAD;
            }
        } else {
            croak( "Your vendor has not defined Authen::Libwrap macro $constname" );
        }
    } else {
        eval "sub $AUTOLOAD { $val }";
        goto &$AUTOLOAD;
    }
}


$DEBUG = 0;

# keep require happy
1;


__END__


=head1 NAME

Authen::Libwrap - access to Wietse Venema's TCP Wrappers library

=head1 SYNOPSIS

  use Authen::Libwrap qw( hosts_ctl STRING_UNKNOWN );

  # we know the remote username (using identd)
  $rc = hosts_ctl(	"programname",
			"hostname.domain.com",
			"10.1.1.1",
			"username" );
  );
  print "Access is ", $rc ? "granted" : "refused", "\n";

  # we don't know the remote username
  $rc = hosts_ctl(	"programname",
			"hostname.domain.com",
			"10.1.1.1",
			STRING_UNKNOWN );
  );
  print "Access is ", $rc ? "granted" : "refused", "\n";

=head1 DESCRIPTION

The Authen::Libwrap module allows you to access the hosts_ctl() function from
the popular TCP Wrappers security package.  This allows validation of
network access from perl programs against the system-wide F<hosts.allow>
file.

If any of the parameters to hosts_ctl() are not known (i.e. username due to
lack of an identd server), the constant STRING_UNKNOWN should be passed to
the function.

=begin testing

use_ok('Authen::Libwrap');
Authen::Libwrap->import( qw|hosts_ctl STRING_UNKNOWN| );
ok( defined(&hosts_ctl), "'hosts_ctl' function is exported");
Authen::Libwrap::STRING_UNKNOWN();        # to make AUTOLOAD generate it
ok( defined(&STRING_UNKNOWN), "'STRING_UNKNOWN' constant is exported");

my $daemon = "tcp_wrappers_test";
my $hostname = "localhost";
my $hostaddr = "127.0.0.1";
my $username = STRING_UNKNOWN();

my $result = hosts_ctl( $daemon, $hostname, $hostaddr, $username );
is( $result, 1, 'access is granted');

=end testing

=head1 EXPORTS

  Nothing unless you ask for it.

  hosts_ctl( $daemon, $hostname, $ip_address, $username );

=head1 CONSTANTS

  STRING_UNKNOWN

=head1 BUGS

Calls to hosts_ctl() which match a line in F<hosts.allow> that uses the
"twist" option will terminate the running perl program.  This is not a bug
in Authen::Libwrap per se -- libwrap uses exec(3) to replace the running
process with the specified program, so there's nothing to return to.

Some operating systems ship with a default catch-all rule in F<hosts.allow>
that uses the twist option.  You may have to modify this configuration to
use Authen::Libwrap effectively.

=head1 SEE ALSO

L<Authen::Tcpdmatch>, a Pure Perl module that can parse hosts.allow and
hosts.deny if you don't need all the underlying features of libwrap.

=head1 AUTHOR

James FitzGibbon, E<lt>james@ehlo.comE<gt>

=head1 SEE ALSO

hosts_access(3), hosts_access(5), hosts_options(5)

=cut

#
# EOF
