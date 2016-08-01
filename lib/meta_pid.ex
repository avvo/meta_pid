defmodule MetaPid do
  defmacro __using__(into: into, name: name) do
    quote bind_quoted: [ into: into, name: name ] do
      use GenServer

      @server_name name
      @into into

      def start_link(options \\ []) do
        GenServer.start_link(__MODULE__, nil, name: @server_name)
      end

      def stop() do
        GenServer.stop(@server_name)
      end

      def register_pid(pid, data \\ struct(@into)) do
        GenServer.call(@server_name, {:register_pid, pid, data})
      end

      def put_pid(pid, data) do
        GenServer.call(@server_name, {:update_pid, pid, data})
      end

      def fetch_pid(pid) do
        GenServer.call(@server_name, {:fetch_pid, pid})
      end

      def unregister_pid(pid) do
        GenServer.call(@server_name, {:unregister_pid, pid})
      end

      def get_registry() do
        GenServer.call(@server_name, :get_registry)
      end

      def init(_) do
        {:ok, %{}}
      end

      def handle_call({:register_pid, pid, data}, _from, registry) do
        exit_callback(pid)
        {:reply, :ok, Map.put(registry, pid, data)}
      end

      def handle_call({:update_pid, pid, data}, _from, registry) do
        # handle not present case?
        {:reply, :ok, Map.put(registry, pid, data)}
      end

      def handle_call({:unregister_pid, pid}, _from, registry) do
        {:reply, :ok, Map.delete(registry, pid)}
      end

      def handle_call({:fetch_pid, pid}, _from, registry) do
        {:reply, Map.fetch(registry, pid), registry}
      end

      def handle_call(:get_registry, _from, registry) do
        {:reply, registry, registry}
      end

      defp exit_callback(pid) do
        spawn(fn ->
          Process.monitor(pid)

          receive do
            {:DOWN, _, _, _, _} -> __MODULE__.unregister_pid(pid)
          end
        end)
      end
    end
  end
end
