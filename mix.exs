defmodule Caffeine.MixProject do
  use Mix.Project

  def project do
    [
      name: "Caffeine",
      app: :caffeine,
      version: "1.0.1",
      description: description(),
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: documentation(),
      aliases: aliases(),
      package: package(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:stream_data, "~> 0.4", only: [:test, :dev]},
      {:dialyxir, "~> 0.5", only: [:test, :dev]},
      {:ex_doc, "~> 0.18", only: [:test, :dev]},
      {:excoveralls, "~> 0.8", only: [:test, :dev]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/ancillary.ex"]
  defp elixirc_paths(:dev), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  defp documentation do
    [main: "Caffeine"]
  end

  defp aliases do
    [docs: ["docs", &picture/1]]
  end

  defp package do
    [
      licenses: ["GNU GPLv3"],
      maintainers: ["Joseph Yiasemides"],
      files: ["lib", "mix.exs", "README.md"],
      links: %{"GitHub" => "https://github.com/Dzol/caffeine/"}
    ]
  end

  defp description do
    """
    A stream library with an emphasis on simplicity
    """
  end

  defp picture(_) do
    File.cp("./coffee.jpeg", "./doc/coffee.jpeg")
  end
end
