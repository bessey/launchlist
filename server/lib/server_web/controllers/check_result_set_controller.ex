defmodule ServerWeb.CheckResultSetController do
  use ServerWeb, :controller
  alias Server.{Repo}
  alias Server.Checker.{CheckResultSet, CheckResult}
  import Ecto.Query

  plug(ServerWeb.RequireAuth)

  def edit(conn, %{"id" => id, "pull_request_id" => pr_id}) do
    case CheckResultSet
         |> preload(check_results: ^CheckResult.alphabetical())
         |> CheckResultSet.for_user(get_current_user(conn))
         |> CheckResultSet.for_pull_request(pr_id)
         |> Repo.get(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(ServerWeb.ErrorView)
        |> render("404.html")

      check_result_set ->
        render(conn, "edit.html", check_result_set: check_result_set, pull_request_id: pr_id)
    end
  end

  def update(conn, %{"id" => id, "pull_request_id" => pr_id}) do
    redirect(conn, to: pull_request_check_result_set_path(conn, :edit, pr_id, id))
  end
end
