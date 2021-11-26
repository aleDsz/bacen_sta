defmodule Bacen.STA.MixProject do
  use Mix.Project

  @version System.get_env("VERSION", "0.1.0")

  def project do
    [
      app: :bacen_sta,
      version: @version,
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: dialyzer()
    ] ++ hex()
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:ecto, :ex_machina, :timex, :quinn, :tesla],
      ignore_warnings: ".dialyzerignore"
    ]
  end

  defp hex do
    [
      name: "Bacen STA",
      description: description(),
      package: [
        name: "bacen_sta",
        maintainers: ["Alexandre de Souza"],
        licenses: ["MIT"],
        links: %{"Github" => "https://github.com/aledsz/bacen_sta"}
      ]
    ]
  end

  defp description,
    do: "A Bacen's STA library with facilities to communicate with STA WebService"

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger, :xmerl]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.7.1", optional: true},
      {:telemetry, "~> 1.0", optional: true},
      {:timex, "~> 3.7", optional: true},
      {:ex_machina, "~> 2.7", only: [:dev, :test], optional: true},
      {:credo, "~> 1.5", only: [:dev, :test]},
      {:excoveralls, "~> 0.14", only: :test},
      {:quinn, "~> 1.1", optional: true},
      {:tesla, "~> 1.4", optional: true},
      {:mox, "~> 1.0", only: [:dev, :test]},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      check: [
        "format --check-formatted mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\" \"priv/**/*.{ex,exs}\"",
        "deps.unlock --check-unused",
        "credo --strict",
        "dialyzer --no-check"
      ],
      "format.all": [
        "format mix.exs \"lib/**/*.{ex,exs}\" \"test/**/*.{ex,exs}\""
      ]
    ]
  end
end
