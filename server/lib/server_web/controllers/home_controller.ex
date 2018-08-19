defmodule ServerWeb.HomeController do
  use ServerWeb, :controller
  alias Server.GitHub.{Repository}

  def index(conn, _params) do
    current_user = get_current_user(conn)

    repos =
      if current_user do
        Repository
        |> Repository.for_user(current_user)
        |> Repository.alphabetical()
        |> Server.Repo.all()
      else
        []
      end

    render(conn, "index.html", current_user: current_user, repositories: repos)
  end
end
