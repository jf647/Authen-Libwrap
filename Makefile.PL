use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Authen::Libwrap',
    'VERSION_FROM' => 'Libwrap.pm', # finds $VERSION
    'LIBS'	=> ['-L/usr/local/lib -lwrap'],   # e.g., '-lm' 
    'DEFINE'	=> '',     # e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '-I/usr/local/include',     # e.g., '-I/usr/include/other' 
    'dist'	=> { COMPRESS => 'gzip -9nf', SUFFIX => 'gz' }
);
