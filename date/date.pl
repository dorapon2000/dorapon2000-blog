use 5.30.0;
use strict;
use warnings;
use utf8; # 埋め込みの文字列リテラルがutf8の内部文字列として解釈される
use Encode qw/encode_utf8/; # 日本語を含む内部文字列を標準出力できるutf8バイナリに変換する用

use Time::Piece;
use Time::Seconds qw/ONE_DAY ONE_HOUR ONE_MINUTE/;

# 現在時刻/今日のTime::Piece
my $now = localtime;
my $today = do {
    my $now = localtime;
    my $today = Time::Piece->strptime($now->ymd, "%Y-%m-%d");
    localtime($today);
};

# 文字列 → Time::Piece型
my $t_nopadding = Time::Piece->strptime('2022/2/10 1:00:00', '%Y/%m/%e %k:%M:%S');
my $t_padding = Time::Piece->strptime('2022-02-10 01:00', '%Y-%m-%d %H:%M');
my $t_iso = Time::Piece->strptime('2022-02-10T01:00:00', '%Y-%m-%dT%H:%M:%S');

# Time::Piece型 → 文字列
say $now->ymd('/'), ' ', $now->hms; # 2022/02/20 21:21:47
say $now->datetime; # 2022-02-20T21:21:47
say $now->strftime('%Y年%m月%d日 %H時%M分%S秒'); # 2022年02月20日 21時21分47秒

# 曜日を日本語で取得
my @week_names = qw/日 月 火 水 木 金 土/;
say encode_utf8($now->wdayname(@week_names)); # 日

# 足し算と引き算
my $future = $now + ONE_DAY * 10 + ONE_HOUR * 10 + ONE_MINUTE * 10 + 10;
say $future; # Thu Mar  3 07:31:57 2022

my $past = $now - ONE_DAY * 10 - ONE_HOUR * 10 - ONE_MINUTE * 10 - 10;
say $past; # Thu Feb 10 11:11:37 2022

# 比較
say $past < $future ? 'True' : 'False'; # True

# タイムゾーン
# FIXME
