# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

use Sys::Hostname;
use Socket;

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use Authen::Libwrap qw( hosts_ctl STRING_UNKNOWN );
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

$daemon = "tcp_wrappers_test";
$hostname = "localhost";
$hostaddr = "127.0.0.1";
$username = STRING_UNKNOWN;

$result = hosts_ctl( $daemon, $hostname, $hostaddr, $username );
print "ok 2\n";

$Authen::Libwrap::DEBUG = 1;
print "ok 3\n";
