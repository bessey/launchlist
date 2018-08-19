defmodule ServerWeb.CheckResultController do
  use ServerWeb, :controller
  alias Server.{Repo, Checker}
  alias Server.Checker.{CheckResult, Check}
  alias Server.Checker.Parser.{Check}

  plug(ServerWeb.RequireAuth)

  def update(conn, %{"id" => id, "pull_request_id" => pr_id, "check_params" => check_params}) do
    with check_result <- get_check_result(conn, pr_id, id),
         {:ok, _} <- update_single_check(check_result, check_params),
         {:ok, _} <- Checker.update_check_result_set_status(check_result.check_result_set_id) do
      conn
      |> put_resp_header(
        "X-PJAX-URL",
        pull_request_check_result_set_path(conn, :edit, pr_id, check_result.check_result_set_id)
      )

      redirect(
        conn,
        to:
          pull_request_check_result_set_path(conn, :edit, pr_id, check_result.check_result_set_id)
      )
    else
      error ->
        conn |> send_resp(:bad_request, inspect(error))
    end
  end

  defp get_check_result(conn, pr_id, id) do
    CheckResult
    |> CheckResult.for_user(get_current_user(conn))
    |> CheckResult.for_pull_request(pr_id)
    |> Repo.get(id)
  end

  defp update_single_check(
         check_result,
         %{
           "set" => set,
           "check_set_index" => check_set_index,
           "check_index" => check_index
         }
       ) do
    new_value =
      update_in(
        check_result.result,
        [
          Access.key!(:list),
          check_set_index |> String.to_integer() |> Access.at(),
          Access.key!(:checks),
          check_index |> String.to_integer() |> Access.at()
        ],
        &%Check{&1 | set: set == "true"}
      )

    check_result
    |> CheckResult.changeset(%{result: new_value})
    |> Repo.update()
  end
end
