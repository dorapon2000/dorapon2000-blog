use 5.32.1;
use warnings;
use utf8;

use DateTime;
use DateTime::Format::Strptime;

my $strp_YmdHMS = DateTime::Format::Strptime->new(
    pattern   => '%Y-%m-%d %H:%M:%S',
    locale    => 'ja',
    time_zone => 'local',
);
my $dt_0224_59 = $strp_YmdHMS->parse_datetime('2023-02-24 23:59:59');
my $dt_0225_00 = $strp_YmdHMS->parse_datetime('2023-02-25 00:00:00');
my $dt_0225_01 = $strp_YmdHMS->parse_datetime('2023-02-25 00:00:01');
my $dt_0226_00 = $strp_YmdHMS->parse_datetime('2023-02-26 00:00:00');

say $dt_0224_59->delta_days($dt_0225_00)->delta_days; # 1
say $dt_0225_00->delta_days($dt_0225_01)->delta_days; # 0
say $dt_0224_59->delta_days($dt_0226_00)->delta_days; # 2
