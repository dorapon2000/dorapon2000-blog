#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p certs && cd certs
openssl req -x509 -newkey rsa:2048 -nodes -days 30 \
  -keyout server.key -out server.crt -subj '/CN=a.example.com' \
  -extensions san -config /dev/stdin <<CONF
[req]
distinguished_name = dn
[dn]
[san]
subjectAltName = DNS:a.example.com,DNS:b.example.net
CONF
openssl x509 -in server.crt -pubkey -noout \
  | openssl pkey -pubin -outform der \
  | openssl dgst -sha256 -binary | base64 > spki.txt
