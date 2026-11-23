#!/bin/sh
# 使い方は README の Usage を参照
set -eu
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
mkdir -p profiles logs
: > logs/test.log
if [ -n "${BLOCK_AFTER_NAV:-}" ]; then
  rm -f "block/$BLOCK_AFTER_NAV"
  (until grep -q '/nav.js' logs/test.log; do sleep 0.2; done; touch "block/$BLOCK_AFTER_NAV") &
  WATCHER_PID=$!
fi
"$CHROME" \
  --user-data-dir="profiles/$1" \
  --host-resolver-rules="MAP *.example.com 127.0.0.1,MAP *.example.net 127.0.0.1" \
  --ignore-certificate-errors-spki-list="$(cat certs/spki.txt)" \
  --no-first-run --no-default-browser-check \
  --use-mock-keychain --password-store=basic \
  --disable-background-networking --disable-component-update \
  "$2" 2>/dev/null &
CHROME_PID=$!
if [ -n "${WAIT:-}" ]; then
  wait "$CHROME_PID"
else
  sleep 5
  kill -INT "$CHROME_PID"
  wait "$CHROME_PID" || true
fi
if [ -n "${BLOCK_AFTER_NAV:-}" ]; then
  kill "$WATCHER_PID" 2>/dev/null || true
  rm -f "block/$BLOCK_AFTER_NAV"
fi
echo '--- ページの結果 ---'
sed -n 's|^https://[^/]*/report?\(.*\) 204$|\1|p' logs/test.log | tr '&' '\n' | sed 's/%3A/:/g; s/%2F/\//g; s/=/: /'
echo '--- nginx に届いたリクエスト ---'
grep -v '/report?' logs/test.log || true
