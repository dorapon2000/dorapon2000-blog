# Abstract

「ハッシュ値の INDEX は先頭何文字で足りるか」の検証コードです。

255 文字のランダムな 16 進数の文字列を入れた `VARCHAR(255)` の列に、次の 6 パターンの INDEX を張り、SELECT・INSERT・UPDATE の速さを比べます。

| パターン | INDEX |
| --- | --- |
| `none` | 無し |
| `p4` | `INDEX (hash(4))` |
| `p8` | `INDEX (hash(8))` |
| `p16` | `INDEX (hash(16))` |
| `p32` | `INDEX (hash(32))` |
| `full` | `INDEX (hash)` |

| 操作 | SQL |
| --- | --- |
| `select_val` | `SELECT val FROM t WHERE hash = ?` |
| `select_id` | `SELECT id FROM t WHERE hash = ?` |
| `insert` | `INSERT INTO t VALUES (?, ?, 0)` |
| `update_val` | `UPDATE t SET val = val + 1 WHERE hash = ?` |
| `update_hash` | `UPDATE t SET hash = ? WHERE id = ?` |

計測はすべて `sql/procedures.sql` のストアドプロシージャーで行います。クライアントとの通信の時間を含めないためです。

# Requirements

- Docker と Docker Compose
- ディスクの空き 6GB（500 万行のとき）

macOS 15.8.1、Docker 29.9.3（CPU 8 個、メモリー 8GB）で確かめました。

# Setup

```sh
cd prefix_index
docker compose up -d --wait
```

# Usage

```sh
./run.sh <行数> <操作の回数> <INDEX なしのときの操作の回数>
```

テーブルを作り直し、パターンごとに INDEX のサイズと、操作ごとの時間を表示します。

- 操作ごとに 1 回空回ししてから 3 回測り、その中央値を 1 回あたりの時間にします。
- INSERT と UPDATE は 1 つのトランザクションで行い、測った後に ROLLBACK します。
- INDEX なしの SELECT と `update_val` は全件を読むので、操作の回数を減らせるようにしています。

記事では次の 2 つを実行しました。結果は `results/` にあります。1 万行は 2 分、500 万行は 45 分ほどかかりました。

```sh
(time ./run.sh 10000 10000 1000) > results/10000.txt 2>&1
(time ./run.sh 5000000 10000 5) > results/5000000.txt 2>&1
```

`my.cnf` で `innodb_buffer_pool_size` を 128MB にしています。500 万行のときに、INDEX が buffer pool に乗りきらないようにするためです。

# Cleanup

```sh
docker compose down -v
```
