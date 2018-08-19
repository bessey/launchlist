defmodule ServerWeb.PullRequestController do
  use ServerWeb, :controller
  alias Server.{Repo}
  alias Server.GitHub.{PullRequest}
  import Ecto.Query

  plug(ServerWeb.RequireAuth)

  def index(conn, _params) do
    pull_requests =
      PullRequest
      |> PullRequest.for_user(get_current_user_id(conn))
      |> Repo.all()

    render(conn, "index.html", pull_requests: pull_requests)
  end

  def show(conn, %{"id" => id}) do
    pull_request =
      from(
        PullRequest,
        preload: [check_runs: :check_result_set]
      )
      |> PullRequest.for_user(get_current_user_id(conn))
      |> Repo.get(id)

    render(conn, "show.html", pull_request: pull_request)
  end
end
