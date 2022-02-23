use 5.30.0;
use strict;
use warnings;

use utf8;
binmode STDOUT, ":utf8";

my $en = "English";
say $en, " : ", length($en), " 文字";

my $ja = "日本語";
say $ja, " : ", length($ja), " 文字";
