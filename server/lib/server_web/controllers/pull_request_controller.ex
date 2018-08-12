defmodule ServerWeb.PullRequestController do
  use ServerWeb, :controller
  alias Server.{Repo}
  alias Server.GitHub.{Repository, PullRequest}
  import Ecto.Query

  plug(ServerWeb.RequireAuth)

  def index(conn, _params) do
    pull_requests =
      PullRequest
      |> scope_to_user(conn)
      |> Repo.all()

    render(conn, "index.html", pull_requests: pull_requests)
  end

  def show(conn, %{"id" => id}) do
    pull_request =
      from(
        PullRequest,
        preload: [check_runs: :check_result_set]
      )
      |> scope_to_user(conn)
      |> Repo.get(id)

    render(conn, "show.html", pull_request: pull_request)
  end

  defp scope_to_user(query, conn) do
    from(
      pr in query,
      join: r in assoc(pr, :repository),
      join: u in assoc(r, :users),
      where: u.id == ^get_current_user_id(conn)
    )
  end
end
