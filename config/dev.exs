use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :pitch_in, PitchIn.Web.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["server.js", cd: Path.expand("../assets", __DIR__)]]

# Watch static and templates for browser reloading.
config :pitch_in, PitchIn.Web.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/pitch_in/web/views/.*(ex)$},
      ~r{lib/pitch_in/web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :pitch_in, PitchIn.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "pitch_in_dev",
  hostname: "localhost",
  pool_size: 10

config :pitch_in, PitchIn.Mailer,
  adapter: Bamboo.SendgridAdapter,
  server: "smtp.domain",
  port: 1025,
  tls: :if_available, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1

config :pitch_in, :server_env, :local

config :pitch_in, :staging_auth,
  username: "username",
  password: "password",
  realm: "Staging"

config :pitch_in, :cert, "success"
config :pitch_in, :facebook_id, "fb_id"

config :comeonin,
  bcrypt_log_rounds: 4

try do
  # Use dev.secret if it exists.
  import_config "dev.secret.exs"
rescue
  e in Mix.Config.LoadError -> nil
end
