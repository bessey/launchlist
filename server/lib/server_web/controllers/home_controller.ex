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
    check_result_sets =
      CheckResultSet
      |> CheckResultSet.for_user(current_user)
      |> limit(10)
      |> order_by(desc: :inserted_at)
      |> preload(check_run: [pull_request: [:repository]])
      |> Server.Repo.all()

    render(conn, "index.html", current_user: current_user, check_result_sets: check_result_sets)
  end
end
