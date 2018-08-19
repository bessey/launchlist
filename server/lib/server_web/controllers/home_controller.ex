defmodule ServerWeb.HomeController do
  use ServerWeb, :controller
  alias Server.Checker.{CheckResultSet}
  import Ecto.Query

  def index(conn, _params) do
    current_user = get_current_user(conn)
    index_for(conn, current_user)
  end

  defp index_for(conn, nil) do
    render(conn, "pitch.html")
  end

  defp index_for(conn, current_user) do
    common_query =
      CheckResultSet
      |> CheckResultSet.for_user(current_user)
      |> limit(10)
      |> preload(check_run: [pull_request: [:repository]])

    new_check_result_sets =
      common_query
      |> order_by(desc: :inserted_at)
      |> Server.Repo.all()

    updated_check_result_sets =
      common_query
      |> order_by(desc: :updated_at)
      |> Server.Repo.all()

    render(
      conn,
      "index.html",
      current_user: current_user,
      new_check_result_sets: new_check_result_sets,
      updated_check_result_sets: updated_check_result_sets
    )
  end
end
