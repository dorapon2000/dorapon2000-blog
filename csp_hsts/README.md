# Abstract

「default-src https: と upgrade-insecure-requests; と Strict-Transport-Security の違い」の検証コードです。

- 80 番ポートの nginx は、HTTP の通信を書き換える攻撃者の役です。どのホストのどのパスにも、攻撃者のページを返します。
- 443 番ポートの nginx は、本物のサイトの役です。パスごとに付けるヘッダーを変えています。
- ホストは、例示用に予約されたドメインを使います。

| ホスト | 役 |
| --- | --- |
| `a.example.com` | 自分のサイト |
| `b.example.net` | 他人のサイト |
| `old.example.net` | HTTPS で配信していない、他人のサイト |

| パス | ヘッダー |
| --- | --- |
| `/none/` | 無し |
| `/csp/` | `Content-Security-Policy: default-src https:` |
| `/uir/` | `Content-Security-Policy: upgrade-insecure-requests` |
| `/both/` | `Content-Security-Policy: upgrade-insecure-requests; default-src https:` |
| `/hsts/` | `Strict-Transport-Security: max-age=31536000` |

# Requirements

- macOS と Google Chrome
- Docker と Docker Compose
- openssl

macOS 15.8.1、Google Chrome 158.0.8127.36、Docker 29.9.3、LibreSSL 3.3.6 で確かめました。`run.sh` は macOS の Chrome のパス（`/Applications/Google Chrome.app`）を使います。

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

画面のある Chrome で URL を開き、5 秒後に終了してから、ページの結果と nginx に届いたリクエストを表示します。実行のたびに Chrome のウィンドウが前面に出ます。

- `WAIT=1` を付けると、Chrome を ⌘Q で終了するまで待ちます。警告の画面で「サイトへ移動」を押すときに使います。
- `BLOCK_AFTER_NAV=<ホスト名>` を付けると、`nav.html` を開き終えてから、そのホストの HTTPS の妨害を始めます。終わると妨害をやめます。
- Chrome の状態は、プロファイル名ごとに `profiles/` に残ります。
    - HSTS の検証は、同じプロファイル名で続けて実行します。
    - それ以外は、毎回新しいプロファイル名を使ってください。Chrome は、警告を無視して http で開いたホストを覚えます。
    - 記事のコマンドをもう一度通すときは、先に `rm -rf profiles` で消してください。

開くページは次の 3 つです。記事の「手入力」は、`run.sh` に http の URL を直接渡して代わりにしています。

- `/<パス>/test.html`: いろいろなホストの img と script を読み込み、結果を nginx の `/report` に送る
- `/<パス>/nav.html?to=<URL>&wait=<秒>`: 開くと自動で `<URL>` へのリンクをクリックする。`wait` を付けると、その秒数だけ待ってからクリックする
- `/landing.html`: リンクや手入力で開く先。80 番では攻撃者のページになる

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
