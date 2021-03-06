use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :pitch_in, PitchIn.Web.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :pitch_in, PitchIn.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "pitch_in_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :pitch_in, PitchIn.Mail.Mailer,
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

config :pitch_in, PitchIn.Mail.Mailer,
  api_key: "mailer_key"

config :pitch_in, PitchIn.Mail.Email,
  test_email: "test@pitch-in.us",
  from_email: "from@pitch-in.us",
  contact_us_email: "contact_us@pitch-in.us",
  basic_template_id: "80509523-83de-42b6-a2bf-54b7513bd2aa"
  
config :comeonin,
  bcrypt_log_rounds: 4

import_config "test.mocks.exs"
