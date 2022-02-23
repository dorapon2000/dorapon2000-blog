use 5.30.0;
use strict;
use warnings;

use Encode;
use utf8;

my $en = "English";
say encode_utf8($en . " : " . length($en) . " 文字");

my $ja = "日本語";
say encode_utf8($ja . " : " . length($ja) . " 文字");
