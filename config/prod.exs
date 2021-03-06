use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :pitch_in, PitchIn.Web.Endpoint,
  http: [port: {:system, "PORT"}],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :pitch_in, PitchIn.Web.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  url: [scheme: "https", host: System.get_env("HOST_URL"), port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

# Configure your database
config :pitch_in, PitchIn.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :pitch_in, PitchIn.Mail.Mailer,
  adapter: Bamboo.SendgridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY"),
  server: "smtp.domain",
  port: 1025,
  tls: :if_available, # can be `:always` or `:never`
  ssl: false, # can be `true`
  retries: 1

config :pitch_in, PitchIn.Mail.Email,
  test_email: System.get_env("TEST_EMAIL"),
  from_email: System.get_env("FROM_EMAIL"),
  contact_us_email: System.get_env("CONTACT_US_EMAIL"),
  basic_template_id: System.get_env("SENDGRID_TEMPLATE_ID")

config :pitch_in, :staging_auth,
  username: System.get_env("STAGING_AUTH_USERNAME") || "username",
  password: System.get_env("STAGING_AUTH_PASSWORD") || "password",
  realm: "Staging"

config :pitch_in, :cert, System.get_env("CERT_KEY") || "cert_test.success"
config :pitch_in, :facebook_id, System.get_env("FACEBOOK_APP_ID")

config :pitch_in, :server_env, System.get_env("SERVER_ENV")

# Do not print debug messages in production
config :logger, level: :info


# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :pitch_in, PitchIn.Web.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :pitch_in, PitchIn.Web.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :pitch_in, PitchIn.Web.Endpoint, server: true
#

# Finally import the config/prod.secret.exs
# which should be versioned separately.
# import_config "prod.secret.exs"
