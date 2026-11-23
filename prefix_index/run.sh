#!/bin/sh
# 使い方: ./run.sh <行数> <1 回の計測の操作回数> <INDEX なしの操作回数>
set -eu
cd "$(dirname "$0")"

rows=$1
ops=$2
none_ops=$3

mysql() {
  docker compose exec -T mysql mysql --table bench "$@"
}

mysql < sql/procedures.sql
mysql -e "CALL setup($rows, $ops)"
for pattern in none p4 p8 p16 p32 full; do
  if [ "$pattern" = none ]; then n=$none_ops; else n=$ops; fi
  echo "$pattern" >&2
  mysql -e "CALL bench_pattern('$pattern', $n)" > /dev/null
done
mysql -e "CALL report($rows)"
