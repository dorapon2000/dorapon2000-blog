#!/bin/sh
# 使い方: ./run.sh <プロファイル名> <URL>
# Chrome をヘッドレスで開き、最後の DOM の結果と、nginx に届いたリクエストを表示する。
# 同じプロファイル名で続けて実行すると、HSTS の記録が引き継がれる。
# NETLOG=1 を付けると、Chrome のネットワークのログを logs/netlog.json に書き出す。
set -eu
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
mkdir -p profiles logs
: > logs/test.log
"$CHROME" --headless \
  --user-data-dir="profiles/$1" \
  --host-resolver-rules="MAP *.test 127.0.0.1" \
  --ignore-certificate-errors-spki-list="$(cat certs/spki.txt)" \
  --no-first-run --no-default-browser-check \
  --use-mock-keychain --password-store=basic \
  --disable-background-networking --disable-component-update \
  ${NETLOG:+--log-net-log=logs/netlog.json} \
  --virtual-time-budget=5000 \
  --dump-dom "$2" 2>/dev/null \
  | sed -n -e 's/.*<p id="landing">\(.*\)<\/p>.*/\1/p' -e '/<pre id="result">/,/<\/pre>/p' \
  | sed -e 's/<[^>]*>//g'
echo '--- nginx に届いたリクエスト ---'
sleep 1
cat logs/test.log
