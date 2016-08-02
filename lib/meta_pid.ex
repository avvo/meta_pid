defmodule MetaPid do
  defmacro __using__(into: into, name: name) do
    quote bind_quoted: [ into: into, name: name ] do
      use GenServer

      @type into :: unquote(into)
      @type into_map :: %{pid => unquote(into)}

      @server_name name

      @spec start_link([any()]) :: {:ok, pid()} | {:error, any()}
      def start_link(options \\ []) do
        GenServer.start_link(__MODULE__, nil, name: @server_name)
      end

      def stop() do
        GenServer.stop(@server_name)
      end

      @spec register_pid(pid()) :: atom()
      def register_pid(pid) do
        data = struct(unquote(into))
        GenServer.call(@server_name, {:register_pid, pid, data})
      end

      @spec register_pid(pid(), into()) :: atom()
      def register_pid(pid, data) do
        GenServer.call(@server_name, {:register_pid, pid, data})
      end

      @spec put_pid(pid(), into()) :: atom()
      def put_pid(pid, data) do
        GenServer.call(@server_name, {:update_pid, pid, data})
      end

      @spec fetch_pid(pid()) :: {:ok, into()} | :error
      def fetch_pid(pid) do
        GenServer.call(@server_name, {:fetch_pid, pid})
      end

      @spec unregister_pid(pid()) :: atom()
      def unregister_pid(pid) do
        GenServer.call(@server_name, {:unregister_pid, pid})
      end

      @spec get_registry() :: into_map()
      def get_registry() do
        GenServer.call(@server_name, :get_registry)
      end

      @spec init([any()]) :: {:ok, into_map()}
      def init(options \\ []) do
        {:ok, %{}}
      end

      @spec handle_call(arg, {pid(), any()}, into_map()) :: {:reply, atom(), into_map()} when arg: {atom(), pid(), into()}
      @spec handle_call(arg, {pid(), any()}, into_map()) :: {:reply, atom(), into_map()} when arg: {:unregister_pid, pid()}
      @spec handle_call(arg, {pid(), any()}, into_map()) :: {:reply, :error | {:ok, into()}, map()} when arg: {:fetch_pid, pid()}
      @spec handle_call(arg, {pid(), any()}, into_map()) :: {:reply, into_map(), into_map()} when arg: :get_registry

      def handle_call({:register_pid, pid, data}, _from, registry) do
        exit_callback(pid)
        {:reply, :ok, Map.put(registry, pid, data)}
      end

      def handle_call({:update_pid, pid, data}, _from, registry) do
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

      @spec exit_callback(pid) :: pid
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
