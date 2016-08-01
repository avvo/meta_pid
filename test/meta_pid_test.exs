defmodule MetaPidTest do
  use ExUnit.Case
  doctest MetaPid

  defmodule MyTestStruct do
    defstruct [:foo]
  end

  defmodule MetaPidMap do
    use MetaPid, into: MyTestStruct, name: :meta_pid
  end

  setup do
    {:ok, pid} = MetaPidMap.start_link()

    %{server: pid}
  end

  defp new_link() do
    spawn_link(fn () ->
      receive do
        _ -> nil
      end
    end)
  end

  test "stopping kills the process", %{server: pid} do
    assert Process.alive?(pid)
    MetaPidMap.stop()
    refute Process.alive?(pid)
  end

  test "initializes an empty map for the registry" do
    assert MetaPidMap.get_registry() == Map.new
  end

  test "adds a new pid to the registry" do
    pid = new_link()

    MetaPidMap.register_pid(pid)

    assert Map.has_key?(MetaPidMap.get_registry(), pid)
  end

  test "a pid's data can be retrieved once registered" do
    pid = new_link()

    assert :error == MetaPidMap.fetch_pid(pid)

    MetaPidMap.register_pid(pid)

    assert {:ok, _} = MetaPidMap.fetch_pid(pid)
  end

  test "a pid can be optionally registered with data" do
    pid = new_link()

    my_data = %MyTestStruct{foo: :bar}

    MetaPidMap.register_pid(pid, my_data)

    assert MetaPidMap.fetch_pid(pid) == {:ok, my_data}
  end

  test "removes a pid from the registry" do
    pids = Enum.map(0..10, fn (_) -> new_link() end)

    pids
    |> Enum.each(fn(pid) -> MetaPidMap.register_pid(pid) end)

    [to_remove | remaining] = pids

    MetaPidMap.unregister_pid(to_remove)

    assert (MetaPidMap.get_registry() |> Map.keys) == remaining
  end

  test "allows updates of data for a pid" do
    pids     = Enum.map(0..10, fn (_) -> new_link() end)
    data     = %MyTestStruct{foo: :bar}
    new_data = %MyTestStruct{foo: :new_value}

    pids |> Enum.each(fn (pid) -> MetaPidMap.register_pid(pid, data) end)

    [to_change | remaining] = pids

    MetaPidMap.put_pid(to_change, new_data)

    remaining |> Enum.each(fn (pid) ->
      assert MetaPidMap.fetch_pid(pid) == {:ok, data}
    end)

    assert MetaPidMap.fetch_pid(to_change) == {:ok, new_data}
  end

  test "when a process dies, its key is removed from the registry" do
    pids = Enum.map(0..10, fn (_) ->
      spawn(fn -> :timer.sleep(1) end)
    end)

    pids |> Enum.each(&MetaPidMap.register_pid/1)

    :timer.sleep(10)

    assert MetaPidMap.get_registry() == %{}
  end

  test "pid is automatically unregistered if its process terminates before callback is set" do
    pid = spawn(fn () ->
      receive do
        _ -> nil
      end
    end)

    Process.exit(pid, :kill)

    MetaPidMap.register_pid(pid)

    :timer.sleep(1)

    assert :error == MetaPidMap.fetch_pid(pid)
  end
end
