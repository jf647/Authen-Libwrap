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
#line 91 lib/Authen/Libwrap.pm

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


    undef $main::_STDOUT_;
    undef $main::_STDERR_;
}

