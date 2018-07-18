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

    resources("pull_requests", PullRequestController, only: [:index]) do
      resources("working_list_sets", WorkingListSetController, only: [:show])
    end
  end

  scope "/api", ServerWeb do
    pipe_through(:api)

    post("/working_lists", Api.WorkingListController, :create)
  end
end
