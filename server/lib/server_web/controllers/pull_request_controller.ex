defmodule ServerWeb.PullRequestController do
  use ServerWeb, :controller
  alias Server.{Repo, PullRequest}
  import Ecto.Query

  def index(conn, _params) do
    pull_requests = Repo.all(from(p in PullRequest, select: %{ id: p.id }))
    render(conn, "index.html", pull_requests: pull_requests)
  end
end
