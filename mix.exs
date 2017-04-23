defmodule PitchIn.Mixfile do
  use Mix.Project

  def project do
    [app: :pitch_in,
     version: "1.2.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {PitchIn, []},
     applications: [
       :phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
       :phoenix_ecto, :postgrex,
       :timex, :comeonin, :bamboo, :sentry,
       :httpoison, :poison
       # :uberauth, :ueberauth_identity
     ]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.3.0-rc"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:timex, "~> 3.1.7"},
     {:timex_ecto, "~> 3.1.1"},
     {:ecto_enum, "~> 1.0"},
     {:comeonin, "~> 3.0.0"},
     {:bamboo, "~> 0.8"},
     {:basic_auth, "~> 2.0"},
     {:sentry, "~> 3.0.0"},
     {:hackney, "~> 1.7.0", override: true},
     {:httpoison, "~> 0.11.1"},
     {:poison, "~> 2.0"},
     {:credo, "~> 0.7", only: [:dev, :test]},
     {:ex_machina, "~> 2.0", only: :test},

     {:ueberauth, "~> 0.4"},
     {:ueberauth_identity, "~> 0.2"},
     {:canary, "~> 1.1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "db.migrate": ["ecto.migrate", "ecto.dump"],
     "db.rollback": ["ecto.rollback", "ecto.dump"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
