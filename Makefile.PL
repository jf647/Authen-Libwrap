use ExtUtils::MakeMaker;

WriteMakefile(
    NAME       => 'Authen::Libwrap',
    VERSION    => '0.10.1',
    XS_VERSION => 0.010_001,
    LIBS	   => ['-L/usr/local/lib -lwrap'],
    INC  	   => '-I/usr/local/include',
    PREREQ_PM  => {
        'Test::More' => 0.47,
    },
);
