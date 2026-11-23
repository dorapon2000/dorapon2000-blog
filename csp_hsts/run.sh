#!/bin/sh
# 使い方は README の Usage を参照
set -eu
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
mkdir -p profiles logs
: > logs/test.log
PROFILE=$1
URL=$2
set -- \
  --user-data-dir="profiles/$PROFILE" \
  --host-resolver-rules="MAP *.example.com 127.0.0.1,MAP *.example.net 127.0.0.1,MAP *.example.org 127.0.0.1" \
  --ignore-certificate-errors-spki-list="$(cat certs/spki.txt)" \
  --no-first-run --no-default-browser-check \
  --use-mock-keychain --password-store=basic \
  --disable-background-networking --disable-component-update \
  ${NETLOG:+--log-net-log=logs/netlog.json}
if [ -n "${HEADFUL:-}" ]; then
  "$CHROME" "$@" "$URL" 2>/dev/null
else
  "$CHROME" --headless --virtual-time-budget=5000 --dump-dom "$@" "$URL" 2>logs/chrome.log \
    | sed -n -e 's/.*<p id="landing">\(.*\)<\/p>.*/\1/p' -e '/<pre id="result">/,/<\/pre>/p' \
    | sed -e 's/<[^>]*>//g'
  sed -n 's/.*Page load failed: \(.*\)/ページを開けなかった: \1/p' logs/chrome.log
fi
echo '--- nginx に届いたリクエスト ---'
cat logs/test.log
