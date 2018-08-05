use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :server, ServerWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :debug

# Configure your database
config :server, Server.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "server_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :server,
  github_oauth_client_id: "1234",
  github_oauth_client_secret: "abcd",
  github_webhook_secret: "beefcafe"

config :tesla, adapter: Tesla.Mock
