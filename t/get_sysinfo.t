#!/usr/bin/perl

use warnings;
use strict;
use Test::More tests => 11;
use AIX::SysInfo;

my %hash = get_sysinfo();
my @items = qw/hostname serial_num num_procs total_ram total_swap aix_version model_type
		proc_speed sys_arch lpar_name lpar_id/;

ok( defined $hash{"$_"}, "$_" ) foreach @items;
