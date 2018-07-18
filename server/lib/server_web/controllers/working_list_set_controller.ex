defmodule ServerWeb.WorkingListSetController do
  use ServerWeb, :controller
  alias Server.{Repo, WorkingList, PullRequest}
  import Ecto.Query

  def index(conn, _params) do
    working_lists = Repo.all(WorkingList)
    render(conn, "index.html", working_lists: working_lists)
  end

  def show(conn, %{"id" => id, "pull_request_id" => pr_id}) do
    pr = Repo.get(PullRequest, pr_id)

    query =
      from(
        w in WorkingList,
        where: w.pull_request_id == ^pr.id
      )

    if working_list = Repo.all(query) do
      render(conn, "show.html", working_list: working_list)
    else
      conn
      |> put_status(:not_found)
      |> put_view(ServerWeb.ErrorView)
      |> render("404.html")
    end
  end
end
