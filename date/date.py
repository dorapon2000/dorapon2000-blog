import locale
import datetime

# 現在時刻/今日のDateTime
dt_now = datetime.datetime.now()
dt_today = datetime.datetime.today()

# 文字列 → DateTime型
dt_nopadding = datetime.datetime.strptime('2022/2/10 1:00:00', '%Y/%m/%d %H:%M:%S')
dt_padding = datetime.datetime.strptime('2022-02-10 01:00', '%Y-%m-%d %H:%M')
dt_iso = datetime.datetime.fromisoformat('2022-02-10T01:00:00')

# DateTime型 → 文字列
print(dt_now.strftime('%Y年%m月%d日 %H時%M分%S秒'))  # 2022年02月20日 19時46分43秒
print(dt_now.isoformat())  # 2022-02-20T19:46:43.466040

# 曜日を日本語で取得
locale.setlocale(locale.LC_TIME, 'ja_JP.UTF-8')
print(dt_now.strftime('%a'))  # 日

# 足し算と引き算
td_10d10h10m10s = datetime.timedelta(days=10, seconds=10, minutes=10, hours=10)
print(dt_now + td_10d10h10m10s)  # 2022-03-03 05:56:53.466040
print(dt_now - td_10d10h10m10s)  # 2022-02-10 09:36:33.466040

# 比較
print(dt_now < dt_now + td_10d10h10m10s)  # True

# タイムゾーン
tz_jst = datetime.timezone(datetime.timedelta(hours=9))
dt_now_jst = datetime.datetime.now(tz=tz_jst)
print(dt_now_jst)  # 2022-02-20 19:46:43.470019+09:00
