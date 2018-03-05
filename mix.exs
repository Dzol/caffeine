defmodule Caffeine.MixProject do
  use Mix.Project

  def project do
    initialize()

    [
      name: "Caffeine",
      app: :caffeine,
      version: "0.1.0",
      description: description(),
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      package: package(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:stream_data, "~> 0.4"}, {:dialyxir, "~> 0.5"}, {:ex_doc, "~> 0.18.3"}]
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

  defp initialize do
    unless ".dialyzer" in File.ls!() do
      File.mkdir!(".dialyzer")
    end
  end

  defp dialyzer do
    [plt_core_path: ".dialyzer"]
  end

  defp picture(_) do
    File.cp("./coffee.jpeg", "./doc/coffee.jpeg")
  end
end
