#
# $Id$
#

use strict;
use warnings;

use Module::Build;

Module::Build->new(

    module_name          => 'Authen::Libwrap',

    dist_version         => '0.11',

    license              => 'perl',
    
    build_requires       => {
        'Test::More' => 0,
    },

    create_makefile_pl   => 'passthrough',

    extra_linker_flags   => '-lwrap',

)->create_build_script;

#
# EOF
