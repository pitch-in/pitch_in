# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :pitch_in,
  ecto_repos: [PitchIn.Repo]

# Configures the endpoint
config :pitch_in, PitchIn.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zOqh1hLfoP3/dzXyth7TYlVQSEZDHiTNGkuDtm1CRABd7tImDxeMPuTxEriWJsoQ",
  render_errors: [view: PitchIn.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PitchIn.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    identity: {Ueberauth.Strategy.Identity, [
      callback_methods: ["POST"],
      param_nesting: "user"
    ]}
  ]

config :sentry, dsn: System.get_env("SENTRY_DSN") || "",
  included_environments: ~w(prod staging),
  environment_name: System.get_env("SERVER_ENV") || "local"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
