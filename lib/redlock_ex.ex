defmodule RedlockEx do
  @moduledoc """
  A module to handle distributed locking using Redis.

  This module provides functionality to attempt to acquire a lock in a distributed system using a Redis backend. It is useful in environments such as Kubernetes where you have multiple instances running and you want to ensure that a particular task is only performed by one of them at any given time.

  ## Examples

      iex> RedlockEx.attempt_acquire_lock(my_redis_conn, "my_lock", 60)
      :acquired

      iex> RedlockEx.attempt_acquire_lock(my_redis_conn, "my_lock", 60)
      :not_acquired
  """

  alias Redix
  @prefix "redlock_ex"

  @doc """
  Attempts to acquire a distributed lock with a specified TTL (Time To Live).

  The function tries to acquire a lock by the name provided, and with the specified TTL, using the Redis `SET` command with `NX` and `EX` options.

  ## Parameters

    - `redis_conn`: The Redis connection.
    - `lock_name`: The unique name identifying the lock.
    - `ttl_in_seconds`: The time to live for the lock, in seconds. After this duration, the lock will be automatically released.

  ## Returns

    - `:acquired`: If the lock was successfully acquired.
    - `:not_acquired`: If the lock could not be acquired, indicating that another process holds the lock.

  ## Examples

      iex> RedlockEx.attempt_acquire_lock(my_redis_conn, "my_unique_lock", 60)
      :acquired

      iex> RedlockEx.attempt_acquire_lock(my_redis_conn, "my_unique_lock", 60)
      :not_acquired
  """
  def attempt_acquire_lock(redis_conn, lock_name, ttl_in_seconds) do
    full_lock_name = @prefix <> "-" <> lock_name

    case Redix.command(redis_conn, [
           "SET",
           full_lock_name,
           "1",
           "NX",
           "EX",
           Integer.to_string(ttl_in_seconds)
         ]) do
      {:ok, "OK"} -> :acquired
      _ -> :not_acquired
    end
  end
end
