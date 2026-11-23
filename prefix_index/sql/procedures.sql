CREATE TABLE IF NOT EXISTS result (
  rows_n INT NOT NULL,
  pattern VARCHAR(8) NOT NULL,
  op VARCHAR(16) NOT NULL,
  run INT NOT NULL,
  ops INT NOT NULL,
  elapsed_us BIGINT NOT NULL,
  bp_reads BIGINT NOT NULL,      -- buffer pool に無く、ディスクから読んだページ数
  bp_requests BIGINT NOT NULL,   -- buffer pool に読みに行ったページ数
  rows_read BIGINT NOT NULL,     -- InnoDB から読んだ行数
  PRIMARY KEY (rows_n, pattern, op, run)
);

CREATE TABLE IF NOT EXISTS index_size (
  rows_n INT NOT NULL,
  pattern VARCHAR(8) NOT NULL,
  primary_bytes BIGINT NOT NULL,
  index_bytes BIGINT NOT NULL,
  PRIMARY KEY (rows_n, pattern)
);

DROP PROCEDURE IF EXISTS setup;
DROP PROCEDURE IF EXISTS bench_pattern;
DROP PROCEDURE IF EXISTS bench_op;
DROP PROCEDURE IF EXISTS report;

DELIMITER //

-- 255 文字のランダムな 16 進数の文字列を p_rows 行作り、パターンごとのテーブルの元にする
CREATE PROCEDURE setup(IN p_rows INT, IN p_ops INT)
BEGIN
  DELETE FROM result WHERE rows_n = p_rows;
  DELETE FROM index_size WHERE rows_n = p_rows;
  DROP TABLE IF EXISTS t, src, probe, nums;

  CREATE TABLE nums (n INT PRIMARY KEY);
  INSERT INTO nums
    WITH RECURSIVE c (n) AS (SELECT 0 UNION ALL SELECT n + 1 FROM c WHERE n < 999)
    SELECT n FROM c;

  CREATE TABLE src (
    id INT PRIMARY KEY,
    hash VARCHAR(255) NOT NULL,
    val INT NOT NULL
  );
  -- 同じ行数なら毎回同じ値になるよう、id から SHA-256 を 4 つつなげて作る
  INSERT INTO src
    SELECT id,
           LEFT(CONCAT(SHA2(CONCAT(id, 'a'), 256), SHA2(CONCAT(id, 'b'), 256),
                       SHA2(CONCAT(id, 'c'), 256), SHA2(CONCAT(id, 'd'), 256)), 255),
           0
    FROM (SELECT a.n + b.n * 1000 + c.n * 1000000 + 1 AS id
          FROM nums a, nums b, nums c
          WHERE b.n < CEIL(p_rows / 1000) AND c.n < CEIL(p_rows / 1000000)) x
    WHERE id <= p_rows
    ORDER BY id;

  -- 計測で使う値。i 回目の操作は seq = i の行を使う
  --   id, hash: 既存の行。7919 は素数なので、行全体にばらけ、同じ行を 2 回選ばない
  --   new_hash: テーブルに無い値。INSERT と hash の UPDATE で使う
  CREATE TABLE probe (
    seq INT PRIMARY KEY,
    id INT NOT NULL,
    hash VARCHAR(255) NOT NULL,
    new_hash VARCHAR(255) NOT NULL
  );
  INSERT INTO probe
    SELECT x.seq, s.id, s.hash,
           LEFT(CONCAT(SHA2(CONCAT(x.seq, 'new-a'), 256), SHA2(CONCAT(x.seq, 'new-b'), 256),
                       SHA2(CONCAT(x.seq, 'new-c'), 256), SHA2(CONCAT(x.seq, 'new-d'), 256)), 255)
    FROM (SELECT a.n + b.n * 1000 + 1 AS seq FROM nums a, nums b) x
    JOIN src s ON s.id = (x.seq * 7919) MOD p_rows + 1
    WHERE x.seq <= p_ops;
END//

-- 1 つのパターンのテーブルを作り、操作ごとに 1 回の空回しと 3 回の計測をする
CREATE PROCEDURE bench_pattern(IN p_pattern VARCHAR(8), IN p_ops INT)
BEGIN
  DECLARE v_rows INT;
  DECLARE v_t0 DATETIME(6);
  DECLARE v_run INT;
  DECLARE v_i INT;
  DECLARE v_op VARCHAR(16);

  SELECT COUNT(*) INTO v_rows FROM src;

  DROP TABLE IF EXISTS t;
  CREATE TABLE t LIKE src;
  INSERT INTO t SELECT * FROM src;

  IF p_pattern <> 'none' THEN
    SET v_t0 = SYSDATE(6);
    SET @ddl = CONCAT('ALTER TABLE t ADD INDEX idx_hash (hash',
                      IF(p_pattern = 'full', '', CONCAT('(', SUBSTRING(p_pattern, 2), ')')),
                      ')');
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    INSERT INTO result VALUES (v_rows, p_pattern, 'add_index', 1, 1,
                               TIMESTAMPDIFF(MICROSECOND, v_t0, SYSDATE(6)), 0, 0, 0);
  END IF;

  ANALYZE TABLE t;
  INSERT INTO index_size
    SELECT v_rows, p_pattern,
           SUM(IF(index_name = 'PRIMARY', stat_value, 0)) * @@innodb_page_size,
           SUM(IF(index_name = 'idx_hash', stat_value, 0)) * @@innodb_page_size
    FROM mysql.innodb_index_stats
    WHERE database_name = 'bench' AND table_name = 't' AND stat_name = 'size';

  SET v_i = 1;
  WHILE v_i <= 5 DO
    SET v_op = ELT(v_i, 'select_val', 'select_id', 'insert', 'update_val', 'update_hash');
    SET v_run = 0;
    WHILE v_run <= 3 DO
      CALL bench_op(v_rows, p_pattern, v_op, p_ops, v_run);
      SET v_run = v_run + 1;
    END WHILE;
    SET v_i = v_i + 1;
  END WHILE;
END//

CREATE PROCEDURE bench_op(IN p_rows INT, IN p_pattern VARCHAR(8), IN p_op VARCHAR(16),
                          IN p_ops INT, IN p_run INT)
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE v_id INT;
  DECLARE v_hash VARCHAR(255);
  DECLARE v_new_hash VARCHAR(255);
  DECLARE v_x INT;
  DECLARE v_t0 DATETIME(6);
  DECLARE v_elapsed BIGINT;
  DECLARE r0, q0, w0, r1, q1, w1 BIGINT;

  -- 書き込みは 1 つのトランザクションで行い、計測の後に ROLLBACK する。
  -- 計測を繰り返しても、テーブルの中身が変わらないようにするため
  IF p_op IN ('insert', 'update_val', 'update_hash') THEN
    START TRANSACTION;
  END IF;

  SELECT SUM(IF(VARIABLE_NAME = 'Innodb_buffer_pool_reads', VARIABLE_VALUE, 0)),
         SUM(IF(VARIABLE_NAME = 'Innodb_buffer_pool_read_requests', VARIABLE_VALUE, 0)),
         SUM(IF(VARIABLE_NAME = 'Innodb_rows_read', VARIABLE_VALUE, 0))
    INTO r0, q0, w0
    FROM performance_schema.global_status;
  -- NOW() は文の開始時刻を返すので、実行した時刻を返す SYSDATE() を使う
  SET v_t0 = SYSDATE(6);

  WHILE i <= p_ops DO
    SELECT id, hash, new_hash INTO v_id, v_hash, v_new_hash FROM probe WHERE seq = i;
    CASE p_op
      WHEN 'select_val' THEN SELECT val INTO v_x FROM t WHERE hash = v_hash;
      WHEN 'select_id' THEN SELECT id INTO v_x FROM t WHERE hash = v_hash;
      WHEN 'insert' THEN INSERT INTO t VALUES (1000000000 + i, v_new_hash, 0);
      WHEN 'update_val' THEN UPDATE t SET val = val + 1 WHERE hash = v_hash;
      WHEN 'update_hash' THEN UPDATE t SET hash = v_new_hash WHERE id = v_id;
    END CASE;
    SET i = i + 1;
  END WHILE;

  SET v_elapsed = TIMESTAMPDIFF(MICROSECOND, v_t0, SYSDATE(6));
  SELECT SUM(IF(VARIABLE_NAME = 'Innodb_buffer_pool_reads', VARIABLE_VALUE, 0)),
         SUM(IF(VARIABLE_NAME = 'Innodb_buffer_pool_read_requests', VARIABLE_VALUE, 0)),
         SUM(IF(VARIABLE_NAME = 'Innodb_rows_read', VARIABLE_VALUE, 0))
    INTO r1, q1, w1
    FROM performance_schema.global_status;

  IF p_op IN ('insert', 'update_val', 'update_hash') THEN
    ROLLBACK;
  END IF;

  IF p_run > 0 THEN
    INSERT INTO result VALUES (p_rows, p_pattern, p_op, p_run, p_ops, v_elapsed,
                               r1 - r0, q1 - q0, w1 - w0);
  END IF;
END//

-- 3 回の計測の中央値を、操作 1 回あたりに直して出す
CREATE PROCEDURE report(IN p_rows INT)
BEGIN
  SELECT pattern,
         ROUND(primary_bytes / 1024 / 1024, 1) AS primary_mib,
         ROUND(index_bytes / 1024 / 1024, 1) AS index_mib
  FROM index_size
  WHERE rows_n = p_rows
  ORDER BY FIELD(pattern, 'none', 'p4', 'p8', 'p16', 'p32', 'full');

  SELECT pattern, ROUND(elapsed_us / 1000) AS add_index_ms
  FROM result
  WHERE rows_n = p_rows AND op = 'add_index'
  ORDER BY FIELD(pattern, 'p4', 'p8', 'p16', 'p32', 'full');

  SELECT pattern, op,
         ROUND(elapsed_us / ops, 1) AS us_per_op,
         ROUND(min_us / ops, 1) AS min,
         ROUND(max_us / ops, 1) AS max,
         ROUND(bp_reads / ops, 2) AS disk_reads_per_op,
         ROUND(bp_requests / ops, 1) AS page_reads_per_op,
         -- probe から読む 1 行を引く
         ROUND(rows_read / ops - 1, 1) AS rows_read_per_op
  FROM (SELECT r.*,
               ROW_NUMBER() OVER w AS rn,
               COUNT(*) OVER (PARTITION BY pattern, op) AS cnt,
               MIN(elapsed_us) OVER (PARTITION BY pattern, op) AS min_us,
               MAX(elapsed_us) OVER (PARTITION BY pattern, op) AS max_us
        FROM result r
        WHERE rows_n = p_rows AND op <> 'add_index'
        WINDOW w AS (PARTITION BY pattern, op ORDER BY elapsed_us)) x
  WHERE rn = CEIL(cnt / 2)
  ORDER BY FIELD(op, 'select_val', 'select_id', 'insert', 'update_val', 'update_hash'),
           FIELD(pattern, 'none', 'p4', 'p8', 'p16', 'p32', 'full');
END//

DELIMITER ;
