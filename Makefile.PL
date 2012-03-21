
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "A Mouse role for processing command line options",
  "AUTHOR" => "NAKAGAWA Masaki <masaki\@cpan.org>, FUJI Goro <gfuji\@cpan.org>, Stevan Little <stevan\@iinteractive.com>, Brandon L. Black <blblack\@gmail.com>, Yuval Kogman <nothingmuch\@woobling.org>, Ryan D Johnson <ryan\@innerfence.com>, Drew Taylor <drew\@drewtaylor.com>, Tomas Doran <bobtfish\@bobtfish.net>, Florian Ragwitz <rafl\@debian.org>, Dagfinn Ilmari Mannsaker <ilmari\@ilmari.org>, Avar Arnfjord Bjarmason <avar\@cpan.org>, Chris Prather <perigrin\@cpan.org>, Mark Gardner <mjgardner\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Test::Exception" => "0.21",
    "Test::More" => "0.88",
    "Test::Warn" => "0.21"
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "MouseX-Getopt",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "MouseX::Getopt",
  "PREREQ_PM" => {
    "Getopt::Long" => "2.37",
    "Getopt::Long::Descriptive" => "0.091",
    "Mouse" => "0.64"
  },
  "VERSION" => "0.32",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



