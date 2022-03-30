use 5.30.3;
use strict;
use warnings;

my $vals = ['empty', 'num0', 'str0', 'undef'];
my $str_val_map = {
    empty => '',
    num0  => 0,
    str0  => '0',
    undef => undef,
};

for my $v (@$vals) {
    for my $w (@$vals) {
        next if $v eq $w;
        print "$v == $w: ";

        my $vv = $str_val_map->{$v};
        my $ww = $str_val_map->{$w};

        say($vv == $ww ? 'True' : 'False');
    }
}

for my $v (@$vals) {
    for my $w (@$vals) {
        next if $v eq $w;
        print "$v eq $w: ";

        my $vv = $str_val_map->{$v};
        my $ww = $str_val_map->{$w};

        say($vv eq $ww ? 'True' : 'False');
    }
}
