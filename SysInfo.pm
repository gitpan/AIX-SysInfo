package AIX::SysInfo;

$^W++;
use strict;
use vars qw(@ISA @EXPORT $VERSION);
require Exporter;

@ISA = qw(Exporter);

# %EXPORT_TAGS = ( 'all' => [ qw(   ) ] );

# @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw( get_sysinfo );

$VERSION = "1.0";

#======================================================================

$^O =~ /aix/i || die "This module only runs on AIX systems.\n";

sub get_sysinfo {

	my %sysinfo = (

		hostname 	=> &get_hostname,
		serial_num	=> &get_serial_num,
		num_procs	=> &get_num_procs,
		total_ram	=> &get_total_ram,
		total_swap	=> &get_total_swap,
		aix_version	=> &get_aix_version,
		
	);

	@sysinfo{"model_type", "proc_speed", "sys_arch"} = &get_hardware_info;

	return %sysinfo

};


sub get_hostname {

  chomp(my $hostname = `/usr/bin/hostname`);
  
  return $hostname

};

sub get_serial_num {

  my $serial_num = substr(`/usr/bin/uname -m`, 2, 6); 
  
  return $serial_num

};

sub get_num_procs {

  my $num_proc;
  
  open (LSCFG, "/usr/sbin/lscfg -vp|");
  
  while (<LSCFG>) {
  
    next unless $_ =~ m/\s+proc\d{1,}/;
    
    $num_proc++
  };
  
  close (LSCFG);
  
  return $num_proc

};

sub get_total_ram {

  my $total_ram;
  
  open (LSATTR, "/usr/sbin/lsattr -El sys0|");
  
  while (<LSATTR>) {
  
    next unless $_ =~ m/^realmem/;
    
    (undef, $total_ram) = split(/\s+/, $_);
    
    last

  };
  
  close (LSATTR);
  
  $total_ram = ($total_ram / 1024);
  
  return $total_ram

};

  
sub get_total_swap {

  my $total_swap;

  open (LSPS, "/usr/sbin/lsps -s|");
  
  while (<LSPS>) {

    if ( $_ =~ m/\s+(\d{1,})MB/) { $total_swap = $1 };
    
  };

  close (LSPS);

  return $total_swap

};


sub get_aix_version {

  my @ml;

  open (INSTFIX, "/usr/sbin/instfix -i|");

  while (<INSTFIX>) {

    next unless /\s+All filesets for (.*)_AIX_ML/;

    my $ml = $1;

    $ml =~ s/\.//g;

    push (@ml, $ml);

  };

  close (INSTFIX);

  my @ml_sorted = sort { $b cmp $a } @ml;

  return $ml_sorted[0]

};

sub get_model_id {

  my $model = &hardware_info("model");
  
  return $model
  
};

sub processor_arch {

  my $arch = &hardware_info("arch");
  
  return $arch
  
};

sub processor_speed {

  my $speed = &hardware_info("speed");
  
  return $speed
  
}

sub get_hardware_info {

  my $infowanted = shift || "ALL"; 

  my ($model, $speed, $arch);


  my %rs6k = ( 
    '02' => { model => "7015-930", speed => "25", arch  => "Power" },
    '10' => { model => "7013-530 or 7016-730",  speed => "25", arch  => "Power" },
    '11' => { model => "7013-450", speed => "30", arch  => "Power" },
    '14' => { model => "7013-540", speed => "30", arch  => "Power" },
    '18' => { model => "7013-53H", speed => "33", arch  => "Power" },
    '1C' => { model => "7013-550", speed => "41.6", arch  => "Power" },
    '20' => { model => "7015-930", speed => "25", arch  => "Power" },
    '2E' => { model => "7015-950", speed => "41", arch  => "Power" },
    '30' => { model => "7013-520", speed => "20", arch  => "Power" },
    '31' => { model => "7012-320", speed => "20", arch  => "Power" },
    '34' => { model => "7013-52H", speed => "25", arch  => "Power" },
    '35' => { model => "7012-32H", speed => "25", arch  => "Power" },
    '37' => { model => "7012-340", speed => "33", arch  => "Power" },
    '38' => { model => "7012-350", speed => "41", arch  => "Power" },
    '41' => { model => "7011-220", speed => "33", arch  => "RSC" },
    '43' => { model => "7008-M20 or 7008-M2A", speed => "33", arch  => "Power" },
    '46' => { model => "7011-250", speed => "66", arch  => "PowerPC" },
    '47' => { model => "7011-230", speed => "45", arch  => "RSC" },
    '48' => { model => "7009-C10", speed => "80", arch  => "PowerPC" },
    '57' => { model => "7012-390 or 7030-3BT or 9076-SP2 Thin", speed => "67", arch  => "Power2" },
    '58' => { model => "7012-380 or 7030-3AT", speed => "59", arch  => "Power2" },
    '59' => { model => "7012-39H or 9076-SP2 Thin", speed => "67", arch  => "Power2" },
    '5C' => { model => "7013-560", speed => "50", arch  => "Power" },
    '63' => { model => "7015-970 or 7015-97B", speed => "50", arch  => "Power" },
    '64' => { model => "7015-980 or 7015-98B", speed => "62.5", arch  => "Power" },
    '66' => { model => "7013-580", speed => "62.5", arch  => "Power" },
    '67' => { model => "7013-570 or 7015-R10", speed => "50", arch  => "Power" },
    '70' => { model => "7013-590 or 9076-SP2 Wide", speed => "66", arch  => "Power2" },
    '71' => { model => "7013-58H", speed => "55", arch  => "Power2" },
    '72' => { model => "7013-59H or 7015-R20 or 9076-SP2 Wide", speed => "66", arch  => "Power2" },
    '75' => { model => "7012-370 or 7012-375 or 9076-SP1 Thin", speed => "62", arch  => "Power" },
    '76' => { model => "7012-360 or 7012-365", speed => "50", arch  => "Power" },
    '77' => { model => "7012-350 or 7012-355 or 7013-55L", speed => "41 or 41.6", arch  => "Power" },
    '79' => { model => "7013-591 or 9076-SP2 Wide", speed => "77", arch => "Power2" },
    '80' => { model => "7015-990", speed => "71.5", arch  => "Power2" },
    '81' => { model => "7015-R24", speed => "71.5", arch  => "Power2" },
    '89' => { model => "7013-595 or 7076-SP2 Wide", speed => "135", arch  => "P2SC" },
    '94' => { model => "7012-397 or 9076-SP2 Thin", speed => "160", arch  => "P2SC" },
    'A0' => { model => "7013-J30", speed => "75", arch  => "PowerPC" },
    'A1' => { model => "7015-J40", speed => "112", arch  => "PowerPC" },
    'F0' => { model => "7007-N40", speed => "50", arch  => "ThinkPad" },
  );

  my $modelid = substr(`/usr/bin/uname -m`, 8, 2);
  
  if (exists($rs6k{$modelid})) {

      ($model, $speed, $arch) = ($rs6k{$modelid}{model}, $rs6k{$modelid}{speed}, $rs6k{$modelid}{arch})

  } elsif ($modelid eq "4C") {

    my $uname = `uname -M`;

    if      ($uname =~ /S70/) { 
    
      ($model, $speed, $arch) = ("7017-S70", "125", "RS64")
      
    } elsif ($uname =~ /S7A/) { 
    
      ($model, $speed, $arch) =  ("7017-S7A", "262", "RD64-II") 
      
    } elsif ($uname =~ /S80/) { 
    
      ($model, $speed, $arch) =  ("7017-S80", "450", "RS-III") 
      
    } elsif ($uname =~ /F40/) {
    
      ($model, $speed, $arch) =  ("7025-F40", "160 or 233", "PowerPC") 
      
    } elsif ($uname =~ /H10/) { 
    
      ($model, $speed, $arch) =  ("7026-H10", "160 or 233", "PowerPC") 
      
    } elsif ($uname =~ /H70/) {
    
      ($model, $speed, $arch) =  ("7026-H70", "340", "RS64-II") 
      
    } elsif ($uname =~ /260/) {
    
      ($model, $speed, $arch) =  ("7043-260", "200", "Power3")
      
    } elsif ($uname =~ /248/) {
    
      ($model, $speed, $arch) =  ("7248-100 or -120 or -132", "100 or 120 or 132", "PowerPersonal")
      
    } elsif ($uname =~ /B50/) {
    
      ($model, $speed, $arch) =  ("7046-B50", "375", "PowerPC") 
      
    } elsif ($uname =~ /042|043/) { 
    
      ($model, $speed, $arch) =  ("7043-140 or -150 or -240", "166 or 200 or 233 or 332 or 375", "PowerPC")
      
    } elsif ($uname =~ /F50|H50|270/)  {

      $model = "7025-F50 or 7026-H50 or 9076-SP Silver Node";
      $arch  = "PowerPC";   
      
      open (LSCFG, "/usr/sbin/lscfg -vp |");

      while (<LSCFG>) {

        next unless (/ZC.*PS/); 

        if    (/PS=0009E4F580/i) { $speed = "166 MHz" }
        elsif (/PS=0013C9EB00/i) { $speed = "332 MHz" }
        else                     { $speed = "UNKN" }
      };
      
      close (LSCFG)
      
    } else { ($model, $speed, $arch) = ("UNKN", "UNKN", "UNKN") };

  } elsif ($modelid =~ /A3|A4|A6|A7/) {
      
    if    ($modelid eq "A3")  { $model = "7015-R30" }
    elsif ($modelid eq "A4")  { $model = "7015-R40 or -R50 or 9076-SP2 High" }
    elsif ($modelid eq "A6")  { $model = "7012-G30" }
    elsif ($modelid eq "A7")  { $model = "7012-G40" }
    else                      { $model = "UNKN" }
    
    $arch = "PowerPC";
    
    open (LSCFG, "/usr/sbin/lscfg -vl cpucard0 |");
  
    while (<LSCFG>) {

      next unless /\s+FRU/;
  
          if    (/(E1D|C1D)/) { $speed = "75" ; last  }
          elsif (/(C4D|E4D)/) { $speed = "112"; last  }
          elsif (/(C4D|E4D)/) { $speed = "200"; last  }
          else                { $speed = "UNKN"} 
      };
 
      close (LSCFG)   
    
  } elsif ($modelid =~ /C0|C4/) {
      
    if    ($modelid eq "C0")  { $model = "7024-E20 or -E30" }
    elsif ($modelid eq "C4")  { $model = "7025-F30" }
    else                      { $model = "UNKN" }
      
    
    $arch = "PowerPC";
    
    open (LSCFG, "/usr/bin/lscfg -vp |");
    
    while (<LSCFG>) {
    
      next unless /.+\(ZA\)\.+PS=\d{1,}/;
      
    };
    
    close (LSCFG);
    
    $speed = $1;
          
  } else { 
  
    ($model, $speed, $arch) = ("UNKN", "UNKN", "UNKN")
    
  };
  
  if    ($infowanted eq "model") { return $model }
  elsif ($infowanted eq "speed") { return $speed }
  elsif ($infowanted eq "arch" ) { return $arch  }
  elsif (defined(wantarray))     { return ($model, $speed, $arch) }
    
};


1;

__END__

=pod
=head1 NAME

AIX::SysInfo -  A Perl module for retrieving information about an AIX (RS/6000) system

=head1 SYNOPSIS

  use AIX::SysInfo;
  
  my %sysinfo = get_sysinfo;
  

=head1 DESCRIPTION

This module provides a Perl interface for accessing information about an RS/6000 machine running the AIX operating system.  It makes available a single function, B<get_sysinfo>, which returns a hash containing the following keys:

=over

=item B<hostname>


The value of this key contains the hostname of the system.

=item B<serial_num>


The value of this key contains the unique ID number for the system.

=item B<num_procs>


The value of this key contains the number of processors in the system.

=item B<total_ram>


The value of this key contains the total amount of RAM in the system, in megabytes.

=item B<total_swap>

The value of this key contains the total amount of swap space in the system, in megabytes.

=item B<aix_version>

The value of this key contains the version of AIX and the latest complete maintenance level on ths system, in the form "VRMF-ML".

=item B<model_type>

The value of this key contains the RS/6000 model type of the system.  See the NOTE below for more information.

=item B<proc_speed>

The value of this key contains the speed of the processors in the system.  See the NOTE below for more information.

=item B<sys_arch>

The value of this key contains the type of processor architecture in the system.  See the NOTE below for more information.

=back
=head1 NOTE

The values for B<model_type>, B<proc_speed>, and B<sys_arch> are obtained by parsing several system values, as described in the IBM TechDoc C<Determining CPU Speed in AIX>, available from I<http://techsupport.services.ibm.com/rs6k/techbrowse/>.  This article describes several methods for determining those pieces of information.  Unfortunately, the methods provided by IBM do not include every RS/6000 model ever made, and some of the methods result in ambiguous results (i.e., multiple values for each key.)  All possible values for each item are returned as a single scalar, separated by the word "or".

=head1 VERSION

1.0 (released 2000-07-03)

=head1 BUGS

Since I do not have access to every combination of hardware and operating system, this module has been tested in only a small subset of possible environments.  Therefor, there may be "unexpected behavior" in some of the environments where I have not been able to test.

For that reason, I'd really appreciate it if people would e-mail me if any of the values produced by this module do not conform with their expectations.

Also, because this is such an early release version, the functions and the types of values returned are subject to change, based on feedback from users.  Don't depend on this module (yet!) for use in production code.

=head1 TO-DO

=over 2

=item *  Find a more definitive way of obtaining some of the information returned by functions in this module.

=item *  Add an object-oriented interface.

=item *  Add many more functions.

=item *  Add features requested by AIX sysadmins (hint, hint!)

=back

=head1 AUTHOR

  Sandor W. Sklar
  <mailto:ssklar@stanford.edu>
  <http://whippet.stanford.edu/~ssklar/>
  
=head1 COPYRIGHT/LICENSE

Copyright (c) 2001, Sandor W. Sklar.  This module is free software.  It may be used, redistributed, and/or modified under the terms of the Perl Artistic License.

=cut
