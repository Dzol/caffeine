defmodule Caffeine.MixProject do
  use Mix.Project

  def project do
    [
      app: :caffeine,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
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

  defp picture(_) do
    File.cp("./coffee.jpeg", "./doc/coffee.jpeg")
  end
end
