use 5.30.3;
use strict;
use warnings;

say(defined ()    ? 1 : 0); # -> 0
say(defined undef ? 1 : 0); # -> 0
say(defined ""    ? 1 : 0); # -> 1
say(defined "0"   ? 1 : 0); # -> 1
say(defined 0     ? 1 : 0); # -> 1

my @l = undef;
$l[0] = "Hello";
say $l[0]; # -> Hello
