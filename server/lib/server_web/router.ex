defmodule ServerWeb.Router do
  use ServerWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ServerWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", HomeController, :index)

    resources("/pull_requests", PullRequestController, only: [:index]) do
    end
  end

  scope "/auth", ServerWeb do
    pipe_through(:browser)

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
    delete("/logout", AuthController, :delete)
  end

  scope "/api", ServerWeb.Api do
    pipe_through(:api)

    resources("/check_result_sets", CheckResultSetController, only: [:create])

    scope "/github", GitHub do
      post("/webhooks", WebhookController, :create)
    end
  end
end
