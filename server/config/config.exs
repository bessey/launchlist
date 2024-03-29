# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :server,
  ecto_repos: [Server.Repo]

# Configures the endpoint
config :server, ServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZhuAQGwjop3ZQohDh38b43AphyzKIqGNLsadnWjEQs3/fioGKHj7VdewWEBBnTGn",
  render_errors: [view: ServerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Server.PubSub, adapter: Phoenix.PubSub.PG2]

config :server,
  github_oauth_client_id: System.get_env("GITHUB_OAUTH_ID"),
  github_oauth_client_secret: System.get_env("GITHUB_OAUTH_SECRET"),
  github_webhook_secret: "vHI7xJU8HJyjxlEB/dbeVEsMI58IdgLA1+cXrqFODnq1QKirtnhndJxVjG9Ji4tI"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_OAUTH_ID"),
  client_secret: System.get_env("GITHUB_OAUTH_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
