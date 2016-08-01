# MetaPid

A simple KV store for aggregating meta data about processes.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `meta_pid` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:meta_pid, git: "https://github.com/avvo/meta_pid.git", branch: "master"}]
    end
    ```

  2. Ensure `meta_pid` is started before your application:

    ```elixir
    def application do
      [applications: [:meta_pid]]
    end
    ```

  3. If registering under OTP, start under a supervisor, i.e.

    ```elixir
    import Supervisor.Spec

    children = [
      worker(MetaPid)
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
    ```

## Example Usage

  ```elixir

  # 1) Register a pid

  pid = self()
  MetaPid.register_pid(pid)


  # 2) Register a pid with some data

  pid = self()
  MetaPid.register_pid(pid, %{asdf: :fdsa})


  # 3) Update a pid's meta data

  MetaPid.update_pid(pid, %{asdf: :new_datum})


  #4) Remove a pid from the registry

  MetaPid.unregister_pid(pid)
  ```
