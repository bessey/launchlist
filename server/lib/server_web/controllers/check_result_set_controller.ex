defmodule ServerWeb.CheckResultSetController do
  use ServerWeb, :controller
  alias Server.{Repo}
  alias Server.Checker.{CheckResultSet, CheckResult, Check}
  alias Server.Checker.Parser.{Check}
  import Ecto.Query

  plug(ServerWeb.RequireAuth)

  def edit(conn, %{"id" => id, "pull_request_id" => pr_id}) do
    case get_check_result_set(conn, pr_id, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(ServerWeb.ErrorView)
        |> render("404.html")

      check_result_set ->
        render(conn, "edit.html", check_result_set: check_result_set, pull_request_id: pr_id)
    end
  end

  def update(conn, %{"id" => id, "pull_request_id" => pr_id, "check_params" => check_params}) do
    case get_check_result_set(conn, pr_id, id)
         |> update_single_check(check_params) do
      {:ok, _} -> redirect(conn, to: pull_request_check_result_set_path(conn, :edit, pr_id, id))
      _ -> redirect(conn, to: pull_request_check_result_set_path(conn, :edit, pr_id, id))
    end
  end

  defp get_check_result_set(conn, pr_id, id) do
    CheckResultSet
    |> preload(check_results: ^CheckResult.alphabetical())
    |> CheckResultSet.for_user(get_current_user(conn))
    |> CheckResultSet.for_pull_request(pr_id)
    |> Repo.get(id)
  end

  defp update_single_check(
         check_result,
         %{
           "set" => set,
           "result_index" => result_index,
           "check_set_index" => check_set_index,
           "check_index" => check_index
         }
       ) do
    {_, new_value} =
      update_in(
        check_result.result,
        [:results, result_index, :list, check_set_index, :checks, check_index],
        &%Check{&1 | set: set == "true"}
      )

    check_result
    |> CheckResultSet.changeset(%{result: new_value})
    |> Repo.update()
  end
end
