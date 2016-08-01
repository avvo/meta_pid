defmodule MetaPidTest do
  use ExUnit.Case
  doctest MetaPid

  defmodule MyTestStruct do
    defstruct [:foo]
  end

  defmodule MetaPidSomeStruct do
    use MetaPid, into: MyTestStruct, name: :meta_pid
  end

  setup do
    {:ok, pid} = MetaPidSomeStruct.start_link()

    %{server: pid}
  end

  defp new_link() do
    spawn_link(fn () ->
      receive do
        _ -> nil
      end
    end)
  end

  test "server is registered under the name specified when using the macro", %{server: pid} do
    assert Process.whereis(:meta_pid) == pid
  end

  test "stopping kills the process", %{server: pid} do
    assert Process.alive?(pid)
    MetaPidSomeStruct.stop()
    refute Process.alive?(pid)
  end

  test "initializes an empty map for the registry" do
    assert MetaPidSomeStruct.get_registry() == Map.new
  end

  test "adds a new pid to the registry" do
    pid = new_link()

    MetaPidSomeStruct.register_pid(pid)

    assert Map.has_key?(MetaPidSomeStruct.get_registry(), pid)
  end

  test "a pid's data can be retrieved once registered" do
    pid = new_link()

    assert :error == MetaPidSomeStruct.fetch_pid(pid)

    MetaPidSomeStruct.register_pid(pid)

    assert {:ok, _} = MetaPidSomeStruct.fetch_pid(pid)
  end

  test "pid registered without data is initialized to an empty struct bound to the MetaPid" do
    pid = new_link()

    MetaPidSomeStruct.register_pid(pid)

    assert {:ok, %MyTestStruct{}} == MetaPidSomeStruct.fetch_pid(pid)
  end

  test "a pid can be optionally registered with data" do
    pid = new_link()

    my_data = %MyTestStruct{foo: :bar}

    MetaPidSomeStruct.register_pid(pid, my_data)

    assert MetaPidSomeStruct.fetch_pid(pid) == {:ok, my_data}
  end

  test "removes a pid from the registry" do
    pids = Enum.map(0..10, fn (_) -> new_link() end)

    pids
    |> Enum.each(fn(pid) -> MetaPidSomeStruct.register_pid(pid) end)

    [to_remove | remaining] = pids

    MetaPidSomeStruct.unregister_pid(to_remove)

    assert (MetaPidSomeStruct.get_registry() |> Map.keys) == remaining
  end

  test "allows updates of data for a pid" do
    pids     = Enum.map(0..10, fn (_) -> new_link() end)
    data     = %MyTestStruct{foo: :bar}
    new_data = %MyTestStruct{foo: :new_value}

    pids |> Enum.each(fn (pid) -> MetaPidSomeStruct.register_pid(pid, data) end)

    [to_change | remaining] = pids

    MetaPidSomeStruct.put_pid(to_change, new_data)

    remaining |> Enum.each(fn (pid) ->
      assert MetaPidSomeStruct.fetch_pid(pid) == {:ok, data}
    end)

    assert MetaPidSomeStruct.fetch_pid(to_change) == {:ok, new_data}
  end

  test "when a process dies, its key is removed from the registry" do
    pids = Enum.map(0..10, fn (_) ->
      spawn(fn -> :timer.sleep(1) end)
    end)

    pids |> Enum.each(&MetaPidSomeStruct.register_pid/1)

    :timer.sleep(10)

    assert MetaPidSomeStruct.get_registry() == %{}
  end

  test "pid is automatically unregistered if its process terminates before callback is set" do
    pid = spawn(fn () ->
      receive do
        _ -> nil
      end
    end)

    Process.exit(pid, :kill)

    MetaPidSomeStruct.register_pid(pid)

    :timer.sleep(1)

    assert :error == MetaPidSomeStruct.fetch_pid(pid)
  end
end
