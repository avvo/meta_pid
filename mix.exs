defmodule MetaPid.Mixfile do
  use Mix.Project

  def project do
    [
      app: :meta_pid,
      version: "0.1.0",
      elixir: "~> 1.3",
      description: description(),
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      dialyzer: [plt_add_deps: :transitive, plt_file: ".local.plt"]
    ]
  end

  def description do
    """
    Library providing scaffolding for storing process-specific information
    for duration of process' lifespan
    """
  end

  defp package do
    [
      name: :meta_pid,
      maintainers: ["Avvo, Inc", "Chris Wilhelm"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/avvo/meta_pid"
      }
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:dialyxir, "~> 0.3.5", only: [:dev, :test]}
    ]
  end
end
