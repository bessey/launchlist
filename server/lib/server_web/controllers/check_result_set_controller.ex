defmodule ServerWeb.CheckResultSetController do
  use ServerWeb, :controller
  alias Server.{Repo}
  alias Server.Checker.{CheckResultSet}
  import Ecto.Query

  def show(conn, %{"id" => id, "pull_request_id" => pr_id}) do
    case Repo.get(
           from(
             c in CheckResultSet,
             preload: [:check_results],
             join: cr in assoc(c, :check_run),
             where: cr.pull_request_id == ^pr_id
           ),
           id
         ) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(HelloWeb.ErrorView)
        |> render("404.html")

      check_result_set ->
        render(conn, "show.html", check_result_set: check_result_set, pull_request_id: pr_id)
    end
  end
end
