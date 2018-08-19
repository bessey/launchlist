defmodule ServerWeb.HomeController do
  use ServerWeb, :controller
  alias Server.GitHub.{Repository}

  def index(conn, _params) do
    current_user = get_current_user(conn)
    index_for(conn, current_user)
  end

  defp index_for(conn, nil) do
    render(conn, "pitch.html")
  end

  defp index_for(conn, current_user) do
    repos =
      Repository
      |> Repository.for_user(current_user)
      |> Repository.alphabetical()
      |> Server.Repo.all()

    render(conn, "index.html", current_user: current_user, repositories: repos)
  end
end
