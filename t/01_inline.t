#!/usr/local/bin/perl -w

use Test::More 'no_plan';

package Catch;

sub TIEHANDLE {
    my($class, $var) = @_;
    return bless { var => $var }, $class;
}

sub PRINT  {
    my($self) = shift;
    ${'main::'.$self->{var}} .= join '', @_;
}

sub OPEN  {}    # XXX Hackery in case the user redirects
sub CLOSE {}    # XXX STDERR/STDOUT.  This is not the behavior we want.

sub READ {}
sub READLINE {}
sub GETC {}

my $Original_File = 'lib/Authen/Libwrap.pm';

package main;

# pre-5.8.0's warns aren't caught by a tied STDERR.
$SIG{__WARN__} = sub { $main::_STDERR_ .= join '', @_; };
tie *STDOUT, 'Catch', '_STDOUT_' or die $!;
tie *STDERR, 'Catch', '_STDERR_' or die $!;

{
    undef $main::_STDOUT_;
    undef $main::_STDERR_;
#line 37 lib/Authen/Libwrap.pm

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


    undef $main::_STDOUT_;
    undef $main::_STDERR_;
}

