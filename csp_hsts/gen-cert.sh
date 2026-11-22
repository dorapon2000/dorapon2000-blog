#!/bin/sh
# a.test / b.test / evil.test の自己署名証明書を作り、Chrome に渡す SPKI のハッシュを表示する
set -eu
cd "$(dirname "$0")"
mkdir -p certs && cd certs
openssl req -x509 -newkey rsa:2048 -nodes -days 30 \
  -keyout server.key -out server.crt -subj '/CN=a.test' \
  -extensions san -config /dev/stdin <<CONF
[req]
distinguished_name = dn
[dn]
[san]
subjectAltName = DNS:a.test,DNS:b.test,DNS:evil.test
CONF
openssl x509 -in server.crt -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary | base64 > spki.txt
cat spki.txt
