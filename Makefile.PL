use strict;
use warnings;
use inc::Module::Install 0.75;

if ($Module::Install::AUTHOR) {
    require Module::Install::AuthorRequires;
    require Module::Install::AuthorTests;
}

name 'MouseX-Getopt';

all_from 'lib/MouseX/Getopt.pm';

requires 'Mouse'        => '0.39';
requires 'Getopt::Long' => '2.37';
requires 'Getopt::Long::Descriptive' => '0.077';

test_requires 'Test::More'       => '0.62';
test_requires 'Test::Exception'  => '0.21';

author_requires 'Test::Pod' => 1.14;
author_requires 'Test::Pod::Coverage' => '1.04';
author_tests('t/author');

auto_set_repository();

WriteAll check_nmake => 0;
