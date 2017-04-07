defmodule MetaPid.Mixfile do
  use Mix.Project

  def project do
    [
      app: :meta_pid,
      build_embedded: Mix.env == :prod,
      deps: deps(),
      description: description(),
      dialyzer: [plt_add_deps: :transitive, plt_file: ".local.plt"],
      elixir: "~> 1.4",
      package: package(),
      start_permanent: Mix.env == :prod,
      version: "0.2.0"
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

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      # NON-PRODUCTION DEPS
      {:dialyxir, "~> 0.4", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
