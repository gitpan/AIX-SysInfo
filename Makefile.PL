use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'AIX::SysInfo',
    'VERSION_FROM'	=> 'SysInfo.pm', # finds $VERSION
	'dist'  => { COMPRESS => "gzip", SUFFIX => "gz" }
);
