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
lack of an identd server), the constant STRING_UNKNOWN may be passed to
the function.

=begin testing

use Test::Exception;

use_ok('Authen::Libwrap');
Authen::Libwrap->import( ':all' );
ok( defined(&hosts_ctl), "'hosts_ctl' function is exported");
ok( defined(&STRING_UNKNOWN), "'STRING_UNKNOWN' constant is exported");

my $daemon = "tcp_wrappers_test";
my $hostname = "localhost";
my $hostaddr = "127.0.0.1";
my $username = STRING_UNKNOWN();

# these tests aren't very comprehensive because the path to hosts.allow
# is set when libwrap is built and I can't tell what the user's rules
# are.  I can make sure they don't croak, but I can't really tell
# if any call to hosts_ctl should give back a true or false value

# call with all four arguments explicitly
lives_ok { hosts_ctl($daemon, $hostname, $hostaddr, $username) }
    'call hosts_ctl with four explicit args';

# use a default user
lives_ok { hosts_ctl($daemon, $hostname, $hostaddr) }
    'call hosts_ctl without a username';

SKIP: {

    skip "not done yet", 6;

    # use an IO::Socket with a username
    use IO::Socket::INET;
    my $sock = IO::Socket::INET->new;
    lives_ok { hosts_ctl($daemon, $sock, $username) }
        'call hosts_ctl with a glob and username';
        
    # use an IO::Socket without a username
    lives_ok { hosts_ctl($daemon, $sock) }
        'call hosts_ctl with a glob and username';
    
    # use a glob with a username
    lives_ok { hosts_ctl($daemon, *STDIN, $username) }
        'call hosts_ctl with a glob and username';
        
    # use a glob without a username
    lives_ok { hosts_ctl($daemon, *STDIN) }
        'call hosts_ctl with a glob and username';
        
    # use a globref with a username
    lives_ok { hosts_ctl($daemon, \*STDIN, $username) }
        'call hosts_ctl with a glob and username';
        
    # use a globref without a username
    lives_ok { hosts_ctl($daemon, \*STDIN) }
        'call hosts_ctl with a glob and username';
};

=end testing

=cut

package Authen::Libwrap;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK %EXPORT_TAGS $DEBUG);

use constant STRING_UNKNOWN => "unknown";

use XSLoader;
use Exporter;

use Carp                qw|croak|;
use Scalar::Util        qw|reftype|;

@ISA = 'Exporter';

# set up our exports
@EXPORT_OK = qw(
	hosts_ctl
	STRING_UNKNOWN
);
%EXPORT_TAGS = (
    functions => [ qw|hosts_ctl| ],
    constants => [ qw|STRING_UNKNOWN| ],
);
{
    my %seen;
    push @{$EXPORT_TAGS{all}},
    grep {!$seen{$_}++} @{$EXPORT_TAGS{$_}} foreach keys %EXPORT_TAGS;
}
Exporter::export_ok_tags('all');

$VERSION = 0.20;

# pull in the XS parts
XSLoader::load 'Authen::Libwrap', $VERSION;

# set this to a true value to enable C-level debugging
$DEBUG = 0;

=head1 FUNCTIONS

Authen::Libwrap has only one function, though it can be invoked
in several ways.  In each case, an true return code indicates that
the connection is allowed per the rules in F<hosts.allow> and an
undef value indicates the opposite.

=head2 hosts_ctl($daemon, $hostname, $ip_addr, [ $user ] )

=head2 hosts_ctl($daemon, GLOB, [ $user ] )

=head2 hosts_ctl($daemon, $socket, [ $user ] )

=cut

sub hosts_ctl
{
    
    warn("@ARGV\n");
    
    my $daemon = shift;
    my $hostname;
    my $ip_addr;
    my $user;
    
    $DB::single = 1;
    
    # next arg could be a literal hostname or a socket or a glob
    if( UNIVERSAL::isa(ref $_[0], 'IO::Socket::INET') ) {
        
        # try to get hostname and ip addr from socket object
        croak("not done yet");
        
    }
    elsif( reftype  $_[0]  eq 'IO'     ||
           reftype  $_[0]  eq 'GLOB'   ||
           reftype \$_[0]  eq 'GLOB' )
    {
        
        # try to get hostname and ip addr from glob
        croak("not done yet");
        
    }
    else {
        
        # must be a hostname then ip addr
        $hostname = shift;
        $ip_addr = shift;
        
    }

    # if there isn't another argument then we sub one in
    unless( $user = shift ) {
        $user = STRING_UNKNOWN;
    }
    
    # dispatch to the XS function
    return _hosts_ctl($daemon, $hostname, $ip_addr, $user);
    
}

# keep require happy
1;


__END__

=head1 EXPORTS

Nothing unless you ask for it.

hosts_ctl optionally

STRING_UNKNOWN optionally

=head1 EXPORT_TAGS

=over 4

=item * B<functions>

 hosts_ctl

=item * B<constants>

 STRING_UNKNOWN

=item * B<all>

everything the module has to offer.

=back

=head1 CONSTANTS

 STRING_UNKNOWN

=head1 BUGS

=over 4

=item * B<twist> in F<hosts.allow>

Calls to hosts_ctl() which match a line in F<hosts.allow> that uses the
"twist" option will terminate the running perl program.  This is not a bug
in Authen::Libwrap per se -- libwrap uses exec(3) to replace the running
process with the specified program, so there's nothing to return to.

Some operating systems ship with a default catch-all rule in F<hosts.allow>
that uses the twist option.  You may have to modify this configuration to
use Authen::Libwrap effectively.

=item * Test suite is not comprehensive

The test suite isn't very comprehensive because the path to hosts.allow is
set when libwrap is built and I can't tell what the user's rules are. I can
make sure the function calls don't die, but I can't really tell if any call
to hosts_ctl should give back a true or false value.

=back

=head1 TODO

In early 2003 I was contacted by another Perl developer who had developed an
XS interface to libwrap that covered more of the API than mine did.
Originally he offered it as a patch to my module, but at the time I wasn't
in a position to actively maintain anything on CPAN, so I suggested that he
upload it himself. I unfortunately lost the email thread to a disk crash.

As of December 2003 I don't see any other modules professing to support
libwrap.  If that person is still out there, please get in contact with me,
otherwise I'll plan on implementing some of these TODOs in the new year:

=over 4

=item * provide support for hosts_access and request_* functions

=item * develop an OO interface

=back

=head1 SEE ALSO

L<Authen::Tcpdmatch>, a Pure Perl module that can parse hosts.allow and
hosts.deny if you don't need all the underlying features of libwrap.

hosts_access(3), hosts_access(5), hosts_options(5)

=head1 AUTHOR

James FitzGibbon, E<lt>james@ehlo.comE<gt>

=cut

#
# EOF
