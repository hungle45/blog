---
date: '2025-05-11T16:05:36+07:00'
draft: false
title: 'Understanding Redis: Basic concepts'
tags: ['redis', 'distributed-lock']
cover:
    image: 'images/understanding_redis_basic_concepts/cover.png'
references:
    - title: Redis Documentation
      url: https://redis.io/docs/
    - title: Redis in Action - Josiah L. Carlson
      url: https://www.amazon.com/Redis-Action-Josiah-L-Carlson/dp/1617290858
    - title: Redis Explained - Architecture Notes
      url: https://architecturenotes.co/p/redis
    - title: The correct implementation principle of Redis distributed locks, evolution process and Redission actual combat summary
      url: https://segmentfault.com/a/1190000041172633/en
    - title: Top caching strategies - ByteByteGo
      url: https://blog.bytebytego.com/p/top-caching-strategies
---

Redis is an open-source, in-memory storage that works well as a distributed key-value database, cache, and message broker.

Redis is mainly used as a cache in front of a more substantial database, such as MySQL to enhance application performance. By having the capacity to read and write data to memory quickly, it offloads some workloads from the main database for:

- Data with infrequent updates but high request rates, such as bank configuration details (bank name, bank code, supported transaction types,…).
- Data that is non-essential to core operations and frequently changing, such as rate limits (real-time tracking of how many transactions or API requests a user has made within the current rate limit period).

## 1. Data Structures

Unlike traditional key-value stores that associate string keys with string values, Redis can hold more complex data structures as values, such as Lists, Sets, Sorted Sets, Hashes, Streams, and HyperLogLogs.

### Redis Keys

In Redis, the key serves as the unique identifier for data stored in the database. It’s binary-safe, which means it can represent any sequence of bytes, from simple strings (even empty strings) to complex data structures like binary files.

Redis key expiration allows keys to be automatically removed from the database after a specified period, enabling efficient management of memory resources and ensuring data freshness by automatically clearing out stale or outdated data.

```bash
# Sets the key my_key with the value my_value and an expiration time of 60s.
SET my_key my_value EX 60
```

### Redis Values

Redis values can be simple strings or complex data structures. The most common types of values in Redis include:

- **Strings**: The simplest type, which can hold any binary data up to 512 MB.
- **Lists**: Ordered collections of strings, similar to arrays or linked lists.
- **Sets**: Unordered collections of unique strings, similar to mathematical sets.
- **Hashes**: Maps between string field and string values, similar to a dictionary or hash table.
- **Bitmaps**: A data structure that allows for efficient storage and manipulation of bits.

The aggregate data types (i.e., Hash, List, and Set) can have up to $2^{32} -1$  $(\sim 4B)$ elements, each of which can have a maximum value size of $512$ MiB.

## 2. Redis Architecture

### Single Redis Instance

{{< figure src="images/understanding_redis_basic_concepts/single_instance.png" align="center" attr="Single Redis Instance" width="80%" >}}

Deploying a single Redis instance is the simplest way to use Redis. It allows users to set up and run small instances easily, helping to expand and speed up their services. However, this approach has a major downside: if the active instance crashes or becomes unavailable, all requests to Redis will fail. This failure would cause a drop in the system’s overall performance and speed.

### Redis High Availability Architecture

{{< figure src="images/understanding_redis_basic_concepts/ha_instance.png" align=center attr="Redis High Availability Architecture" width="80%" >}}

Another common Redis configuration is a primary deployment with a secondary deployment that is kept in sync with replication. One or more instances in your deployment can serve as secondary instances. These instances can help scale Redis reads or provide failover if the primary fails.

An alternative widely used arrangement involves a primary deployment alongside a secondary deployment that consistently mirrors the replication process. These secondary instances encompass one or multiple units within our deployment, facilitating the expansion of read capabilities from Redis. Furthermore, they offer a failover mechanism in scenarios where the primary instance becomes inaccessible.

#### Redis Replication

In Redis, each main instance has a replication ID and an offset, crucial for tracking replication progress and making sync decisions. The offset increases with main instance actions. A new replication ID is created whenever an instance restarts or a replica is promoted to master. After the handshake, the master's replication ID is passed on to connected replicas. Instances with the same ID hold the same data, possibly at different times.

> For instance, if two instances, A and B, share the same replication ID but have offsets of 1000 and 1023 respectively, it means A is missing some commands compared to B. A can catch up to B's state by executing a few commands.

When a replica is behind the main instance, it catches up by replaying commands, achieving sync. If IDs don't match or offsets are unknown, a full synchronization is needed, where the main instance sends a snapshot to the replica. Replication resumes after the sync.

Each Redis instance has two replication IDs because replicas can become masters. After a failover, the new master (previously a replica) remembers the old master's replication ID, aiding other replicas to sync with it partially using the old ID. When a replica becomes a master, it updates its secondary ID to the main ID and notes the offset change, generating a new ID for future use. When new replicas connect, the master checks their IDs and offsets against both its current and secondary IDs, allowing replicas to connect after a failover without full sync.

If the old master reconnects after a failover, it acts as a replica.

### Redis Sentinel

{{< figure src="images/understanding_redis_basic_concepts/sentinel.png" align=center attr="Redis Sentinel" width="80%" >}}

The Redis Sentinel system operates in a distributed manner. It consists of multiple Sentinel processes that work together to ensure high availability for Redis.

Sentinel handles several key tasks:

- **Monitoring:** It continuously checks the status of both the master and replica instances to ensure they are functioning properly.
- **Notification:** Sentinel can notify system administrators or other programs via an API if any Redis instance encounters an issue.
- **Automatic failover:** If the master instance fails, Sentinel triggers a failover process. A replica is promoted to master, other replicas are reconfigured to use the new master, and applications are informed of the new address to connect to.
- **Configuration provider:** Sentinel serves as an authority for clients seeking service discovery. Clients can connect to Sentinels to obtain the address of the current Redis master for a specific service. Sentinels update clients with the new address after a failover.

Using Redis Sentinel in this manner enables failure detection. Multiple sentinel processes agree that the current main instance is no longer available for this detection. This process is called a Quorum, which is the minimum number of votes required for a distributed system to operate such as failover. This number should reflect the number of nodes in the distributed system. In cases where the system must break ties, an odd number of nodes is preferred.

To ensure robustness, it's advisable to run a Sentinel node alongside each application server, if possible. This eliminates concerns about network reachability differences between Sentinel nodes and Redis clients. It's also recommended to have at least three nodes with a quorum of two for reliability.

### Redis Cluster

{{< figure src="images/understanding_redis_basic_concepts/cluster.png" align=center attr="Redis Cluster" width="80%" >}}

Redis Cluster is a distributed implementation of Redis that automatically partitions data across multiple Redis nodes, allowing for horizontal scalability.

In Redis Cluster, data distribution is achieved through sharding, where data is spread across several machines. Redis Cluster employs algorithmic sharding, which involves hashing the key and multiplying the result by the number of shards to determine the shard for a given key. Then, a deterministic hash function is used to ensure that the same key always maps to the same shard, enabling predictable key placement for future reads.

When adding a new shard to the system, a process known as resharding occurs. Resharding involves redistributing data among the existing shards and the new shard to maintain balanced data distribution across the cluster.

#### Hash slots

The Redis cluster utilizes consistent hashing to allocate keys to Redis instances, known as hash slots. The key space is divided among cluster masters into 16384 slots, limiting the cluster size. Each master node manages a subset of hash slots, storing keys and values locally.

An illustrative example is presented below, consider the number of hash slots to be 16383.

- `Instance1` contains hash slots from 0 to 8191,
- `Instance2` contains hash slots from 8192 to 16383.

Now, let’s say we need to add another instance, now the distribution of hash slots comes to

- `Instance1` contains hash slots from 0 to 5460.
- `Instance2` contains hash slots from 5461 to 10992.
- `Instance3` contains hash slots from 10993 to 16383.

#### Gossiping

The health of the Redis Cluster is determined by gossiping. We have three M nodes and three S nodes in the diagram above. All of these nodes are constantly communicating to determine which shards are available and ready to serve requests. If enough shards agree that M1 isn't responding, they can decide that M1 is inactive and promote M1's secondary S1 to master.

## 3. Redis Persistence Models

Persistence in Redis refers to writing the in-memory data to durable storage, ensuring that the data will survive server restarts or crashes.

### Persistence Mode

#### No persistence

Persistence can be disabled completely, which is sometimes done when caching.

```bash
appendonly no
save ""
```

#### Redis Database (RDB)

The RDB persistence performs point-in-time snapshots of your dataset at specified intervals and saves them to disk in `.rdb` file. If you care a lot about your data but still can live with a few minutes of data loss in case of disasters, you can use RDB alone.

By default, Redis uses the following settings:

```bash
save 3600 1    # After 3600 seconds (an hour) if at least 1 change was performed
save 300 100   # After 300 seconds (5 minutes) if at least 100 changes were performed
save 60 10000  # After 60 seconds if at least 10000 changes were performed

# These lines equal to
save 3600 1 300 100 60 10000
```

How it works:

- Redis **forks**. We now have a child and a parent process.
- The child starts to write the dataset to a temporary RDB file.
- When the child is done writing the new RDB file, it replaces the old one.

#### Append Only File (AOF)

Append Only File is a logging mechanism that writes a log file on a disk for every operation performed on the Redis database. The log file is used to reconstruct the database in case of a crash or failure by re-executing all operations preserved in the file.

```bash
#The name of the append-only file (default: "appendonly.aof")
appendfilename "appendonly.aof"
```

##### Log Rewriting

The AOF grows as write operations are performed. For example, incrementing a counter 100 times results in 100 entries in the AOF, though only the final entry is needed to rebuild the current state.

The rewrite process is safe. Redis continues appending to the old file while creating a new one with the minimal operations needed. Once the new file is ready, Redis switches to it and starts appending there.

This allows Redis to rebuild the AOF in the background without interrupting service. When the `BGREWRITEAOF` command is issued, Redis creates the shortest sequence of commands necessary to rebuild the current dataset in memory.

```bash
redis> incr counter
(integer) 1
redis> incr counter
(integer) 2
redis> BGREWRITEAOF
Background append only file rewriting started
redis> quit

root@f1877d80cde0:/data# tail appendonly.aof
*3
$3
SET
$7
counter
$1
2
```

Since **Redis 7.0.0**, a **multi-part AOF mechanism** has been implemented. Instead of a single AOF file, it is now divided into a base file (at most one) and incremental files (potentially more than one). When the AOF is rewritten, the base file represents an initial snapshot of the data in either RDB or AOF format. The incremental files capture changes that have occurred since the last base file was created. All these files are stored in a dedicated directory and tracked by a manifest file.

```bash
root@f1877d80cde0:/data/appendonlydir# ls
appendonly.aof.1.base.rdb  appendonly.aof.1.incr.aof  appendonly.aof.manifest
```

##### Durable levels

The frequency at which Redis syncs data to disk can be specified. There are three options:

- `appendfsync everysec` **(default)**: Saves logs every second. In a disaster, up to one second of data may be lost.
- `appendfsync always`: Saves logs whenever new commands are added to the AOF. This method is slow but very safe.
- `appendfsync no`: Does not save logs, instead relying on the operating system to handle data. This method is quicker but less secure.

### Pros & Cons

#### Redis Database (RDB)

- **Pros**:
  - Compact single-file binary format reduces disk space, good for backups.
  - Faster restarts with large datasets compared to AOF.
  - Maximizes Redis performance by offloading disk I/O to a child process (does not impact server performance).
- **Cons**:
  - Data loss risk if Redis crashes between snapshots.
  - Not suitable for high-frequency write operations.
  - Slower than AOF for large datasets.

#### Append Only File (AOF)

- **Pros**:
  - Higher durability with configurable **fsync** policies.
  - Automatic background log rewriting when the file is too big.
  - Easily understandable and exportable log format.
- **Cons**:
  - Slower than RDB for large datasets.
  - Larger file size compared to RDB.

### When to use?

The RDB can be used for better performance, fast restart, and can live with a few minutes of data loss in case of disasters. For example, a CDN provider uses Redis to store cached content metadata. The metadata is updated infrequently, and RDB snapshots ensure that data can be recovered quickly with minimal loss if necessary.

The AOF can be used for a system that needs high durability when data loss is unacceptable.

> "The general indication you should use both persistence methods is if you want a degree of data safety comparable to what PostgreSQL can provide you." -- <cite>*[Redis Documentation](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/#ok-so-what-should-i-use)*</cite>

Many users are using AOF alone, but it’s discouraged since having an RDB snapshot from time to time is a great idea for doing database backups, for faster restarts, and in the event of bugs in the AOF engine.

## 5. Cache Strategies

> “There are only two hard things in Computer Science: cache invalidation and naming things.” -- <cite>*Phil Karlton*</cite>

### Read Strategies

#### Cache Aside

In Cache-Aside, the application can talk directly to the cache and database. When the application needs to access data, it first checks whether the data is already cached. If cache-hit, the data is returned to the application. If not, the application reads the data from the database and inserts or updates the data in the cache.

- **Pros**
  - The application has explicit control over what data is cached.
  - The data is cached only when it is read, which is called lazy caching. This avoids the cache being filled up with unnecessary data.
- **Cons**
  - There is a risk of serving stale data to the client, especially if the data is updated frequently.

=> Good for read-heavy workloads where data updates can be slightly delayed.

#### Read Through

Instead of talking to both the cache and database like, in the cache-aside strategy, the application just talks with the cache. In this strategy, the data is read directly from the cache. If the required data is not presented, the cache will fetch it from the database and store it in the cache for future access.

- **Pros**
  - The cache is automatically populated as data is requested from the primary source, simplifying cache management.
- **Cons**
  - Stale data may present in the cache if data changes in a database.

=> Good for read-heavy workloads where data updates can be slightly delayed.

### Write Strategies

#### Write Through

A Write-Through Cache is a caching strategy where data is written to the cache and the database simultaneously. When an application writes data, it first writes it to the cache and then to the database, ensuring that the cache is always in sync with the database.

- **Pros**
  - Ensures that the cache is always up to date with the latest data.
  - There is no need for explicit cache invalidation mechanisms since data modifications are immediately reflected in the cache.
- **Cons**
  - Most of the data that occurs in the cache might never be requested.
  - The write operation may have higher latency cause data must be written to both the cache and the database.

=> Ensures strong consistency between the cache and the database.

#### Write Back

A Write-Back Cache is a caching strategy where write operations are first performed on the cache, and then asynchronously updated in the underlying database at a later time. In this strategy, data is initially written to the cache, and the write operation is considered complete, allowing the application to continue without waiting for the data to be persisted to the primary data store immediately.

- **Pros**
  - Reduces the load on the database by batching writes.
  - Improves write performance by allowing data to be written to the cache first and then asynchronously written to the database.
- **Cons**
  - There is a risk of data loss if the cache fails before the data is written to the database.
  - The cache may become inconsistent with the database if not managed properly.

=> Good for write-heavy workloads where data consistency is not critical.

#### Write Around

In Write-Around, the application writes data directly to the database and bypasses the cache. The cache is not updated immediately, and the data is only cached when it is read from the database.

- **Pros**
  - Reduces write load on the cache, which can be beneficial for write-heavy applications.
  - Avoids potential cache pollution with data that may not be frequently read.
- **Cons**
  - The cache may not contain the most recent data, leading to cache misses when the application tries to read the data.

=> Good for write-heavy workloads where data is not frequently read after being written.

## 6. Cache Eviction

The max memory configuration directive configures Redis to use a specified amount of memory for the data set.

```bash
# Set the maximum memory limit to 1GB
maxmemory 1gb
```

If the memory exceeds max memory, the keys are evicted using one of these policies:

- **noeviction**: No keys are evicted. Redis returns an error when the memory limit is reached.
- **allkeys-random**: Evicts random keys from all keys in the dataset.
- **volatile-random**: Evicts random keys from the keys with an expiration set.

### Recency-Based Policies

- **allkeys-lru**: Evicts the least recently used (LRU) keys from all keys in the dataset.
- **volatile-lru**: Evicts the least recently used (LRU) keys from the keys with an expiration set.

=> This policy can be used for caching web pages, and files, where the most recently accessed data is likely to be accessed again soon.

### Time-Based Policies

- **volatile-ttl**: Evicts keys with the shortest time-to-live (TTL) from the keys with an expiration set.

=> This policy can be used for caching data that has a limited lifespan, such as session data or temporary files.

### Frequency-Based Policies

- **allkeys-lfu**: Evicts the least frequently used (LFU) keys from all keys in the dataset.
- **volatile-lfu**: Evicts the least frequently used (LFU) keys from the keys with an expiration set.

=> This policy can be used for caching search results, and frequently accessed data, where the least frequently accessed data is less likely to be accessed again soon.

## 7. Distributed Lock

Local locks are synchronization mechanisms used to control access to shared resources within a single process or on a single machine, typically implemented using constructs like mutexes, semaphores, or file locks. However, local locks cannot maintain data integrity across the distributed environment when applications span multiple machines due to their scope limitations. To address this problem, distributed locks are designed to manage resource access across multiple machines in a distributed system, ensuring mutual exclusion and consistency despite network partitions or node failures.

### Lock with a Single Redis Instance

#### The basic lock

The simplest way to use Redis to lock a resource is to create a key in an instance using the `SET [key] [value] NX` command. This command assigns the **value** to the **key** only if the **key** doesn't already exist, returning 1 upon success and 0 otherwise. When the client needs to release the resource, it deletes the keys using the `DEL [key]`.

However, there needs to be a solution with this approach. The lock might not get released in certain situations:

- If the node where the client is crashes, the lock won't be released properly.
- In cases of abnormal business logic, the `DEL` command might not work.

This means the lock could always be taken, preventing other clients from acquiring it.

#### The basic lock with expiration

To address issues with unable to release locks, Redis's expiration feature is utilized, automatically releasing locks after a specified time with the `SET [key] [value] NX EX` seconds command.

However, another issue arose when client 1's slow execution caused its lock to expire, allowing client 2 to take it, but when client 1 finished and released its lock, it also released client 2's lock inadvertently.

- To prevent such inadvertent releases, a "unique identifier" is set when acquiring the lock (`SET [key] [identifier] NX EX [seconds]`), and upon releasing the lock, the client compares its identifier with the stored identifier before deletion, ensuring only the lock's owner can release it. The following Lua script is used to ensure the release process, which is a GET+DEL instruction is an atomic operation.

    ```lua
    if redis.call("get",KEYS[1]) == ARGV[1] then
        return redis.call("del",KEYS[1])
    else
        return 0
    end
    ```

- To prevent Client 2 from acquiring the lock when Client 1 does not execute completely, Client 1 creates a "watchdog" thread, or a daemon thread, when acquiring the lock to regularly monitor the lock's expiration time and automatically renew it.

### Lock with a Multi-Redis Instance

#### Relock algorithm

To use Redlock, it's recommended to set up at least 5 Redis master nodes on separate machines for fault tolerance

{{< mermaid >}}
sequenceDiagram
    participant Client as Client
    participant RedisCluster as Redis Cluster

    loop Attempt to acquire lock
        Client->>RedisCluster: SET lockKey randomValue NX PX 30000
        alt Lock Acquired
            RedisCluster-->>Client: OK
        else Lock Not Acquired
            RedisCluster-->>Client: NULL
        end
    end

    Note over Client: Ensure the majority of nodes have acquired the lock within a timeout period

    Client->>Client: Calculate elapsed time

    alt Majority Acquired and Elapsed Time < Total Timeout
        Note over Client: Lock Acquired Successfully
    else Lock Not Acquired
        loop Release lock on all nodes
            Client->>RedisCluster: DEL lockKey
        end
    end
{{< /mermaid >}}

Here's how a client acquires a lock:

1. The client obtains the current time `T1` (millisecond level).
2. Try to acquire locks in `N` Redis instances using the same key and a random value.
   - Each request has a timeout period (in milliseconds), significantly shorter than the lock's validity time, allowing quick attempts with the next instance if needed. For example, with a 10-second auto-release time, timeouts could range from about 5 to 50 milliseconds.
3. Calculate the time taken to acquire the lock (`T3 = T2 - T1`), where `T2` is the current time. If the lock is acquired in at least `N/2 + 1` instances and the total time `T3` is less than the lock's validity time, it's considered successful; otherwise, it fails.
4. If the lock in step 3 is successful, then execute the business logic operation to share the resource. Its validity time is considered to be the initial validity time minus the time elapsed, as computed in step 3.
5. If the lock acquisition fails for any reason (e.g., inability to lock N/2 + 1 instances or negative validity time), attempt to unlock all instances, even those believed not to have been locked.

#### Redission Implementation

Besides these above mechanisms, the Redission also uses the pub/sub channel to notify waiting clients that a lock has been released. This avoids the need for clients to continuously poll the lock state, which would be inefficient and could lead to a high Redis server load.

{{< mermaid >}}
sequenceDiagram
    participant ClientA as Client A
    participant ClientB as Client B
    participant Redis as Redis Server

    ClientA->>Redis: SET myLock threadIdA PX 30000 NX
    Redis-->>ClientA: OK (Lock acquired)

    ClientB->>Redis: SET myLock threadIdB PX 30000 NX
    Redis-->>ClientB: NULL (Lock not acquired)
    ClientB->>Redis: SUBSCRIBE lock:myLock:channel

    ClientA->>Redis: DEL myLock
    Redis-->>ClientA: OK (Lock released)
    ClientA->>Redis: PUBLISH lock:myLock:channel "lock_released"
    Redis-->>ClientB: lock_released (Notification)

    ClientB->>Redis: SET myLock threadIdB PX 30000 NX
    Redis-->>ClientB: OK (Lock acquired)
{{< /mermaid >}}
