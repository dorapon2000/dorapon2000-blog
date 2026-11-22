# Abstract

「default-src https: と upgrade-insecure-requests; と Strict-Transport-Security の違い」の検証コードです。

- 80 番ポートの nginx は、HTTP の通信を書き換える攻撃者の役です。どのパスにも「改ざんされた」中身を返します。
- 443 番ポートの nginx は本物のサイトです。パスごとに付けるヘッダーを変えています。
- `old.test` は HTTPS で配信していないホストの想定です。

| パス | ヘッダー |
| --- | --- |
| `/none/` | 無し |
| `/csp/` | `Content-Security-Policy: default-src https:` |
| `/uir/` | `Content-Security-Policy: upgrade-insecure-requests` |
| `/both/` | `Content-Security-Policy: upgrade-insecure-requests; default-src https:` |
| `/hsts/` | `Strict-Transport-Security: max-age=31536000` |

# Requirements

- macOS と Google Chrome（`run.sh` は macOS の Chrome のパスを使う）
- Docker と Docker Compose
- openssl

macOS 15.8.1、Google Chrome 158.0.8127.36、Docker 29.9.3、LibreSSL 3.3.6 で確かめました。nginx は `compose.yaml` で 1.30.7 に固定しています。

80 番と 443 番のポートを使うので、ほかに使っているものがあれば止めてください。

# Setup

```sh
cd csp_hsts
./gen-cert.sh
docker compose up -d
```

自己署名の証明書は、`run.sh` が起動する Chrome にだけ `--ignore-certificate-errors-spki-list` で信頼させます。macOS のキーチェーンには入れません。`*.test` の名前解決も、Chrome の `--host-resolver-rules` で 127.0.0.1 に向けるだけで、`/etc/hosts` は触りません。

# Usage

```sh
./run.sh <プロファイル名> <URL>
```

Chrome をヘッドレスで開き、ページの結果と nginx に届いたリクエストを表示します。同じプロファイル名で続けて実行すると、HSTS の記録が引き継がれます。

# Cleanup

```sh
./cleanup.sh
```

コンテナ・ネットワーク・nginx のイメージ・Chrome のプロファイル・ログ・証明書を消します。
