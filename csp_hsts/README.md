# Abstract

「default-src https: と upgrade-insecure-requests; と Strict-Transport-Security の違い」の検証コードです。

- 80 番ポートの nginx は、HTTP の通信を書き換える攻撃者の役です。どのホストのどのパスにも「改ざんされた」中身を返します。
- 443 番ポートの nginx は、本物のサイトの役です。パスごとに付けるヘッダーを変えています。
- ホストは、例示用に予約されたドメインを使います。

| ホスト | 役 |
| --- | --- |
| `a.example.com` | 自分のサイト |
| `b.example.net` | 他のサイト |
| `evil.example.org` | 攻撃者が用意した HTTPS のサーバー |
| `old.example.net` | HTTPS で配信していないサイト |

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

自己署名の証明書は、`run.sh` が起動する Chrome にだけ `--ignore-certificate-errors-spki-list` で信頼させます。macOS のキーチェーンには入れません。ホストの名前解決も、Chrome の `--host-resolver-rules` で 127.0.0.1 に向けるだけで、`/etc/hosts` は触りません。

# Usage

```sh
./run.sh <プロファイル名> <URL>
```

Chrome をヘッドレスで開き、ページの結果と nginx に届いたリクエストを表示します。

- 同じプロファイル名で続けて実行すると、HSTS の記録が引き継がれます。HSTS と無関係な検証では、毎回新しいプロファイル名を使ってください。Chrome は、警告を無視して http で開いたホストを覚えるからです。
- `NETLOG=1` を付けると、Chrome のネットワークのログを `logs/netlog.json` に書き出します。
- `HEADFUL=1` を付けると、画面のある Chrome で開きます。警告の画面を見るときに使います。ウィンドウを閉じると終わります。

攻撃者が HTTPS を妨害する場面は、`block/<ホスト名>` というファイルで作ります。ファイルがあるあいだ、443 番ポートの nginx はそのホストへの接続を切ります。

```sh
touch block/a.example.com  # 妨害する
rm block/a.example.com     # 妨害をやめる
```

# Cleanup

```sh
./cleanup.sh
```

コンテナ・ネットワーク・nginx のイメージ・Chrome のプロファイル・ログ・証明書・`block/` のファイルを消します。
