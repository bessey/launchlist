defmodule ServerWeb.Api.CheckResultSetController do
  use ServerWeb, :controller
  alias Server.{Checker, GitHub, Repo}
  require Logger

  @doc """
    The official public API endpoint for posting CLI results
  """
  def create(conn, %{
        "token" => token,
        "base_branch" => base_branch,
        "head_sha" => head_sha,
        "results" => data
      }) do
    with {:ok, repo} <-
           if(
             repo = GitHub.get_repository_by_token(token),
             do: {:ok, repo},
             else: {:error, :unauthorized, "Could not find repository for auth token"}
           ),
         {:ok, check_run} <-
           if(
             check_run = GitHub.get_check_run_by_refs(base_branch, head_sha),
             do: {:ok, check_run},
             else: {:error, :not_found, "Check Run not found"}
           ),
         {:ok, result_set} <-
           (
             Logger.info("New check result set for Repo #{repo.id} (#{repo.name})")

             if(
               result_set = Checker.parse_result_set(data),
               do: {:ok, result_set},
               else: {:error, "Could not parse results"}
             )
           ),
         {:ok, check_results} <-
           Repo.transaction(fn ->
             {:ok, check_result_set} =
               Ecto.build_assoc(check_run, :check_result_set, %{version: result_set.version})
               |> Map.from_struct()
               |> Checker.create_check_result_set()

             Enum.map(result_set.results, fn result ->
               create_check_result(check_result_set, result)
             end)
           end),
         {:ok, _} <-
           Enum.reduce(check_results, {:ok, nil}, fn check_result, accumulator ->
             case [accumulator, check_result] do
               [{:ok, _}, {:ok, _}] -> {:ok, nil}
               [{:ok, _}, {:error, error}] -> {:error, inspect(error)}
               [{:error, errors}, {:error, error}] -> {:error, "#{errors}, #{inspect(error)}"}
             end
           end) do
      conn |> put_status(:created) |> json(:ok)
    else
      {:error, status, error} ->
        put_status(conn, status)
        |> json(%{error: error})

      {:error, error} ->
        put_status(conn, :bad_request)
        |> json(%{error: error})
    end
  end

  def create(conn, _) do
    put_status(conn, :bad_request)
    |> json(%{error: "Missing one or more of token / base_branch / head_sha / results"})
  end

  defp create_check_result(check_result_set, %Checker.Parser.Result{} = result) do
    attrs = %{
      name: result.name,
      version: result.version,
      result: struct!(result)
    }

    check_result_set
    |> Ecto.build_assoc(:check_results, attrs)
    |> Map.from_struct()
    |> Checker.create_check_result()
  end
end
