defmodule ServerWeb.CheckListController do
  use ServerWeb, :controller
  alias Server.{Repo, CheckList}

  def index(conn, _params) do
    check_lists = Repo.all(CheckList)
    render(conn, "index.html", check_lists: check_lists)
  end

  def show(conn, %{"id" => id}) do
    if check_list = Repo.get(CheckList, id) do
      render(conn, "show.html", check_list: check_list.data)
    else
      conn
      |> put_status(:not_found)
      |> put_view(ServerWeb.ErrorView)
      |> render("404.html")
    end
  end
end
