defmodule Livemd2exs.MixProject do
  use Mix.Project

  @source_url "https://github.com/andyl/livemd2exs"
  @version "0.1.0"

  def project do
    [
      app: :livemd2exs,
      version: @version,
      description: "Converts .livemd files to .exs",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      package: package(),
      docs: docs(),
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # use `mix escript.build`
  defp escript do
    [main_module: Livemd2exs.CLI]
  end

  defp deps do
    [
      {:earmark, "~> 1.4"},
      {:git_ops, "~> 2.6", only: [:dev, :test]},
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: [
        "README.md"
      ]
    ]
  end

  defp package do
    [
      name: :livemd2exs,
      maintainers: "Andy Leak",
      licenses: ["MIT"],
      links: %{
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md",
        "GitHub" => @source_url
      }
    ]
  end
end
