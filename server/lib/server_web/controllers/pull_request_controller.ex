defmodule ServerWeb.PullRequestController do
  use ServerWeb, :controller
  alias Server.{Repo}
  alias Server.GitHub.{PullRequest}
  import Ecto.Query

  plug(ServerWeb.RequireAuth)

  def index(conn, _params) do
    pull_requests = Repo.all(PullRequest)

    render(conn, "index.html", pull_requests: pull_requests)
  end

  def show(conn, %{"id" => id}) do
    pull_request =
      Repo.get(
        from(
          p in PullRequest,
          preload: [check_runs: :check_result_set]
        ),
        id
      )

    render(conn, "show.html", pull_request: pull_request)
  end
end
