# RedlockEx

Distributed locking mechanism using Redis for BEAM applications.


## Description
`RedlockEx` provides a mechanism to attempt to acquire a distributed lock using Redis. 

### Why Do I Need RedlockEx?
In distributed environments, such as those managed by Kubernetes, it's common to have multiple replicas of your BEAM application running simultaneously. While this redundancy provides resilience and horizontal scalability, it can also introduce challenges when certain operations need to be executed by only one instance, avoiding redundant or conflicting operations.

For instance, consider tasks like:

- Sending out a batch email notification.
- Running a periodic data aggregation.
- Resetting some system-wide counters.

Executing these tasks on every instance would be inefficient, redundant, or even potential dangerous. That's where RedlockEx comes in.

By using RedlockEx, you can ensure that specific operations in your BEAM applications are executed only once across the entire distributed setup, no matter how many replicas you have. It leverages Redis as a distributed lock mechanism, ensuring atomicity and consistency in these operations.


### Installation

Add `RedlockEx` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:redlock_ex, "~> 0.1.0"}
  ]
e
```

Ensure `RedlockEx` is started before your application:

```elixir
def application do
  [applications: [:redlock_ex]]
end
```

### Usage
#### Establishing a Redis Connection
First, establish a connection to your Redis instance. Replace `REDIS_HOST` and `REDIS_PORT` with relevant values:

```elixir
{:ok, conn} = Redix.start_link("redis://REDIS_HOST:REDIS_PORT")
```

#### Acquiring the Lock
To attempt to acquire a lock, you can use the `attempt_acquire_lock/3` function:

```elixir
case RedlockEx.attempt_acquire_lock(conn, "my_unique_lock", 60) do
  :acquired -> IO.puts("Lock acquired!")
  :not_acquired -> IO.puts("Lock is held by another process.")
end
```

#### Understanding Lock TTL (Time To Live)
In the example above, `60` denotes the TTL of the lock in seconds. This means that if the process that holds the lock crashes or doesn't release the lock for any reason, it will automatically be released after 60 seconds.

This automatic expiration mechanism serves a crucial role:

1. **Preventing Deadlocks**: Deadlocks occur when processes permanently compete for resources, causing them to be stuck indefinitely. By having a TTL, we ensure that even if a process holding the lock dies unexpectedly or is delayed, other processes can still eventually acquire the lock. This ensures system progress, making sure no operation is indefinitely halted.
2. **Ensuring Freshness of the Lock**: Sometimes, operations might take longer than anticipated. By setting a TTL, the lock's "freshness" is ensured, meaning no process can hold onto a resource for an unreasonably long time without renewing its claim.
3. **Minimizing Resource Starvation**: In distributed systems, one process might consistently acquire a lock just a split second before another, leading to "starvation" of the latter. TTL ensures that such monopolies are temporary.

**Note**: It's essential to set a TTL that makes sense for your application. It should be long enough for the locked operation to complete under normal conditions but short enough to prevent extended resource monopolies or deadlocks.

### Configuration
Ensure you have a Redis instance running and reachable at the `REDIS_HOST` and `REDIS_PORT` values from above.

### Testing
To run tests:

```elixir
mix test
```

### Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request.

### License
This project is licensed under the MIT License.
