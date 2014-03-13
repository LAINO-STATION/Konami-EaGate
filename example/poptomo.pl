#!/usr/bin/env perl
use utf8;
use 5.010;
use strict;
use warnings;

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

use Term::ReadKey;

use Konami::EaGate;
use Konami::Games::PopnMusic qw/poptomo_list is_poptomo_registered/;

binmode STDOUT, ":encoding(utf8)";
binmode STDERR, ":encoding(utf8)";

my $eagate = Konami::EaGate->new;
unless ($eagate->login( map { ReadMode 2; $_ = <STDIN>; ReadMode 0; $_} (1..2) )) {
    die "Failed to login.";
}

my @poptomo = poptomo_list($eagate);

say "팝토모 목록입니다.";
for (@poptomo) {
    printf("%s\t%s %d\n", $_->name, $_->id, $_->active);
}