defmodule Lobserver.MixProject do
  use Mix.Project

  def project do
    [
      app: :lobserver,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Lobserver.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.0"},
      {:bandit, "~> 1.0"},
      {:websock_adapter, "~> 0.5"},
      {:sizeable, "~> 1.0"},
      {:white_rabbit, ">= 0.1.0", path: "../../tcp/white_rabbit"}
    ]
  end
end
