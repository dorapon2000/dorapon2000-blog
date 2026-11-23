#!/bin/sh
set -eu
cd "$(dirname "$0")"
docker compose down --rmi all
find block -type f ! -name .gitkeep -delete
rm -rf profiles logs certs
