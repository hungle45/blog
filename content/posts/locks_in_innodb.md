---
date: '2025-05-01T22:30:10+07:00'
draft: true
title: 'Locks in InnoDB'
tags: [SQL, MySQL, InnoDB]
math: true
---

InnoDB uses locking in MySQL to handle concurrent data access and ensure consistency.  This is crucial in a database to prevent multiple users or processes from interfering with each other's changes. This post gives an overview of InnoDB lock types, explaining how they work to manage these concurrent operations and maintain data integrity.

CREATE TABLE `books` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `author_id` bigint(20) NOT NULL,
  `title` varchar(255) NOT NULL,
  `borrowed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_books_on_author_id` (`author_id`)
);

INSERT INTO `books` (`author_id`, `title`)
VALUES
  (101, "The Pragmatic Programmer"),
  (102, "Clean Code"),
  (102, "The Clean Coder"),
  (104, "Ruby Under a Microscope");

SELECT THREAD_ID, INDEX_NAME, LOCK_TYPE, LOCK_MODE, LOCK_DATA, LOCK_STATUS
        FROM performance_schema.data_locks
        ORDER BY THREAD_ID, LOCK_TYPE DESC

// console 1
BEGIN;
UPDATE books SET  borrowed=0 WHERE id = '2' LIMIT 1;
ROLLBACK;
COMMIT;

BEGIN;
INSERT INTO books (id, title, author_id, borrowed) VALUES ('5', 'The Great Gatsby', '101', 1);
ROLLBACK;
COMMIT;

// console 2
BEGIN;
SELECT * FROM `books` WHERE `author_id` = '104' LOCK IN SHARE MODE;
INSERT INTO books (id, title, author_id, borrowed) VALUES ('6', 'The Great', '101', 1);
ROLLBACK;
COMMIT;

### Shared and Exclusive Locks

Shared ($S$) locks and exclusive ($X$) locks are **row-level** locks. These are fundamental concepts for ensuring data consistency when multiple transactions access the same data concurrently.

- *$S$ lock*: Allows a transaction to **read** a row.
- *$X$ lock*: Allows a transaction to **update/delete** a row.

**Lock compatibility:**

| Held Lock   | Requested Lock   | Compatible? |
|-------------|------------------|-------------|
| $S$         | $S$              | Yes         |
| $S$         | $X$              | No          |
| $X$         | $S$              | No          |
| $X$         | $X$              | No          |

This means that:

- Many transaction $T$ can hold $S$ lock on the same row $r$ at the same time.
- An $X$ can be granted only when there is no $T$ is holding $S$ or $X$ lock on that row.

*(\*) Note: In addition to row-level locks, InnoDB also supports table-level shared (S) and exclusive (X) locks, though they are less common. These locks affect the entire table and can be acquired using the following MySQL commands:*

```sql
LOCK TABLE ... READ -- shared lock
LOCK TABLE ... WRITE -- exclusive lock
```

### Intention Locks

### Record Locks

> "A record lock is a lock on an index record." -- <cite>*MySQL Documentation[^1]*</cite>

[^1]: [MySQL Documentation: InnoDB Locking](https://dev.mysql.com/doc/refman/8.4/en/innodb-locking.html#innodb-record-locks)

`As simple as it sounds, it is a lock taken on **a specific row** in an index. This can occur when using a primary key, a unique index, or even when accessing or modifying rows through non-unique indexes or during a full table scan.

```sql
-- Example of record lock
SELECT * FROM employees WHERE department = 'Sales' FOR SHARE;
```

The `FOR SHARE` clause requests a $S$ record lock on the rows returned by the query.

### Gap Locks

before understading gap locks, we need to understand [how InnoDB store index]({{< relref "./how_innodb_store_index.md" >}}).

gpap lock = lock on the gap between index records

gap lock -> prevent other transactions from inserting new rows into the gap -> prevent phantom reads

note that there is no difference between $S$ and $X$ gap locks, they do not conflict with each other.

### Next-Key Locks

next-key lock = record lock + gap lock

### Insert Intention Locks

### AUTO-INC Locks

### Predicate Locks for Spatial Indexes

## #Reference

- [MySQL Documentation: InnoDB Locking](https://dev.mysql.com/doc/refman/8.4/en/innodb-locking.html)
- [A Straightforward Guide for MySQL Locks](https://dev.to/eyo000000/a-straightforward-guide-for-mysql-locks-56i1)
- [A Comprehensive (and Animated) Guide to InnoDB Locking](https://jahfer.com/posts/innodb-locks/)
