use 5.30.0;
use strict;
use warnings;
use utf8; # 埋め込みの文字列リテラルがutf8の内部文字列として解釈される
use Encode qw/encode_utf8/; # 漢字を含む内部文字列を標準出力できるutf8バイナリに変換する用

use DateTime;
use DateTime::Format::Strptime;

# 現在時刻/今日のDateTime
my $dt_now = DateTime->now(time_zone => 'local');
my $dt_today = DateTime->now(time_zone => 'local');

# 文字列 → DateTime型
my $strp_YmekMS = DateTime::Format::Strptime->new(
    pattern   => '%Y/%m/%e %k:%M:%S',
    locale    => 'ja',
    time_zone => 'local',
);
my $dt_nopadding = $strp_YmekMS->parse_datetime('2022/2/10 1:00:00');

my $strp_YmdHM = DateTime::Format::Strptime->new(
    pattern   => '%Y-%m-%d %H:%M',
    locale    => 'ja',
    time_zone => 'local',
);
my $dt_padding = $strp_YmdHM->parse_datetime('2022-02-10 01:00');

my $strp_iso = DateTime::Format::Strptime->new(
    pattern   => '%Y-%m-%dT%H:%M:%S',
    locale    => 'ja',
    time_zone => 'local',
);
my $dt_iso = $strp_iso->parse_datetime('2022-02-10T01:00:00');

# DateTime型 → 文字列
say $dt_now->ymd('/'), ' ', $dt_now->hms; # 2022/02/21 00:58:23
say $dt_now->datetime; # 2022-02-21T00:58:23
say encode_utf8($dt_now->strftime('%Y年%m月%d日 %H時%M分%S秒')); # 2022年02月21日 00時58分23秒

# 曜日を日本語で取得
my $dt = DateTime->now(locale => 'ja' , time_zone => 'local');
say encode_utf8($dt->day_abbr); # 月

# 足し算と引き算
my $future = $dt_now->clone;
$future->add(days => 10, hours => 10, minutes => 10, seconds => 10);
say $future; # 2022-03-03T11:08:33

my $past = $dt_now->clone;
$past->subtract(days => 10, hours => 10, minutes => 10, seconds => 10);
say $past; # 2022-02-10T14:48:13

# 比較
say $past < $future ? 'True' : 'False'; # True

# タイムゾーン
my $dt_now_jst = DateTime->now(time_zone => 'Asia/Tokyo');
