---
date: '2025-05-11T16:25:54+07:00'
draft: false
title: 'Redis Interview Questions'
tags: ['redis', 'interview-questions']
references:
  - title: 'Redis Interview Questions - DevInterview'
    url: 'https://devinterview.io/questions/web-and-mobile-development/redis-interview-questions/'
---

This article will cover some of the most common Redis interview questions and answers. If you want to learn more about Redis, check out the [Understanding Redis: Basic concepts]({{< relref "./understanding_redis_basic_concepts.md" >}}).

### Why Redis is so fast?

- **Stores data in RAM rather than on disk**: This allows for extremely fast read and write operations, as accessing data in memory is significantly faster than accessing it on disk.
- **Using a single-threaded model combined with I/O multiplexing**: Redis can handle multiple connections simultaneously without the overhead of thread management.
- **Efficient data structures**: Redis uses highly optimized data structures that are designed for speed and efficiency such as Lists, Sets, Sorted Sets, Hashes, and etc.

### Redis Scan vs. Keys: Which One Should You Use?

`SCAN` and `KEYS` are both used for searching keys in Redis, but they work differently. `KEYS` returns all matched keys in one go, while `SCAN` uses a cursor for incremental iteration.

```bash
# KEYS pattern (O(n))
redis> KEYS *name*
1) "firstname"
2) "lastname"
3) "nickname"

# SCAN cursor [MATCH pattern] [COUNT count] (O(1))
SCAN 0 MATCH *name*
1) "4"
2) 1) "firstname"
SCAN 0 MATCH *name*
1) "0"
2) 1) "lastname"
   2) "nickname"
```

Both commands iterate over all keys. The advantage of `SCAN` is its ability to return only a small number of elements per call, avoiding long server-blocking periods like `KEY`, especially with large datasets. However, while the KEY command can provide all the elements that are part of a Set in a given moment, `SCAN` provides limited guarantees about the returned elements due to potential changes in the collection during iteration.

- `KEYS`: Use this command when you need to find all keys matching a specific pattern. However, be cautious with large datasets, as it can block the server for a long time.
- `SCAN`: Use this command for large datasets or when you want to avoid blocking the server. It’s more efficient and allows for incremental iteration.

### What technique does Redis use to avoid running out of memory when creating RDB snapshots?

{{< figure src="images/redis_interview_questions/forking.png" align="center" attr="Redis Forking" width="70%" >}}

Redis uses the copy-on-write (COW) technique during the fork process to avoid running out of memory when creating RDB snapshots.

- When forking a process, the parent and child share the same physical memory.
- The copy-on-write (COW) technique ensures that both the parent and child processes share the same memory pages until one of them modifies a page.
- When either the parent process attempts to change to a shared page, the operating system makes a copy of the page. The child process is fully unaware of the change and has a consistent memory snapshot. This means that only the pages that are modified after the fork will consume additional memory.

### How should we structure our Redis keys?

[TBU]

### How to handle atomic operations in Redis?

[TBU]

### Pub/Sub model in Redis and how's it implemented?

[TBU]

### What is Redis transaction?

[TBU]

### Redis List and blocking operation in Redis List?

[TBU]

### How to mointor Redis performance?

[TBU]
