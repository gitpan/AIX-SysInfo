#!perl -w

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..2\n"; }
END {print "not ok 1\n" unless $loaded;}
use AIX::SysInfo;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.


print ("\nTesting module AIX::SysInfo version $AIX::SysInfo::VERSION with Perl version $] running on $^O.\n\n");

%allinfo = get_sysinfo;

printf("\n%-20s %-20s\n", "KEY", "VALUE");

print("-" x 40 . "\n");

foreach $key (sort(keys %allinfo)) {

	printf("%-20s %-20s\n", $key, $allinfo{$key});

};

print("\nok 2\n");

