use strict;
use warnings;
use inc::Module::Install;
use 5.008003;

name 'Dezi-Bot';
all_from 'lib/Dezi/Bot.pm';
requires 'Test::More'       => 0;
requires 'SWISH::Prog'      => 0.67;
requires 'Module::Load'     => 0;
requires 'DBIx::Connector'  => 0;
requires 'DBIx::InsertHash' => 0;

perl_version '5.8.3';
license 'http://dev.perl.org/licenses/';
homepage 'https://github.com/karpet/dezi-bot';
bugtracker 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dezi-Bot';
repository 'http://github.com/karpet/dezi-bot';

WriteMakefile(
    PL_FILES => {},
    dist     => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Dezi-Bot* dezi.index' },
);

