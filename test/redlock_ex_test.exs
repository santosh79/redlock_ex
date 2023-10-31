defmodule RedlockExTest do
  # Turn off async due to shared Redis state
  use ExUnit.Case, async: false

  setup_all _context do
    {:ok, conn} = Redix.start_link(host: "host.docker.internal", port: 6379)
    :timer.sleep(1_000)

    {:ok, %{conn: conn}}
  end

  # Cleanup utility to ensure no residual state
  defp cleanup_redis(conn, lock_name) do
    {:ok, _} = Redix.command(conn, ["DEL", lock_name])
  end

  test "acquire lock successfully", %{conn: conn} do
    lock_name = "test_lock"
    ttl = 60

    assert :acquired == RedlockEx.attempt_acquire_lock(conn, lock_name, ttl)

    # Cleanup after acquiring
    cleanup_redis(conn, "redlock_ex-" <> lock_name)
  end

  test "fail to acquire lock after it's already acquired", %{conn: conn} do
    lock_name = "test_lock"
    ttl = 60

    # Acquire once
    assert :acquired == RedlockEx.attempt_acquire_lock(conn, lock_name, ttl)
    # Try to acquire again
    assert :not_acquired == RedlockEx.attempt_acquire_lock(conn, lock_name, ttl)

    # Cleanup
    cleanup_redis(conn, "redlock_ex-" <> lock_name)
  end
end
