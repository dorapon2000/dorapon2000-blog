#!/bin/sh
# 検証で作ったものを片付ける: nginx のコンテナとネットワークとイメージ、Chrome のプロファイル、ログ、証明書
set -eu
cd "$(dirname "$0")"
docker compose down --rmi all
rm -rf profiles logs/* certs/server.crt certs/server.key certs/spki.txt
