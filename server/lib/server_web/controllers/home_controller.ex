defmodule ServerWeb.HomeController do
  use ServerWeb, :controller

  def index(conn, _params) do
    current_user = get_current_user(conn)

    repos =
      if current_user do
        Server.Repo.all(Ecto.assoc(current_user, :repositories), order: :name)
      else
        []
      end

    render(conn, "index.html", current_user: current_user, repositories: repos)
  end
end
