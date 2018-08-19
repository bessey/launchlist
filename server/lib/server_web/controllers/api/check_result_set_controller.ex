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
    with {:ok, repo} <- get_repo_from_token(token),
         {:ok, check_run} <- get_check_run_by_refs(base_branch, head_sha),
         {:ok, result_set} <- parse_result_set(repo, data),
         {:ok, check_results} <- insert_check_results(check_run, result_set),
         {:ok, _} <- reduce_check_results(check_results) do
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

  defp get_repo_from_token(token) do
    if(repo = GitHub.get_repository_by_token(token)) do
      {:ok, repo}
    else
      {:error, :unauthorized, "Could not find repository for auth token"}
    end
  end

  defp get_check_run_by_refs(base_branch, head_sha) do
    if(check_run = GitHub.get_check_run_by_refs(base_branch, head_sha)) do
      {:ok, check_run}
    else
      {:error, :not_found, "Check Run not found"}
    end
  end

  defp parse_result_set(repo, data) do
    Logger.info("New check result set for Repo #{repo.id} (#{repo.name})")

    result_set = Checker.parse_result_set(data)
    {:ok, result_set}
  end

  defp insert_check_results(check_run, result_set) do
    Repo.transaction(fn ->
      {:ok, check_result_set} =
        Checker.upsert_check_result_set(check_run.id, %{version: result_set.version, status: :new})

      Enum.map(result_set.results, fn result ->
        create_check_result(check_result_set, result)
      end)
    end)
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

  defp reduce_check_results(check_results) do
    Enum.reduce(check_results, {:ok, nil}, fn check_result, accumulator ->
      case [accumulator, check_result] do
        [{:ok, _}, {:ok, _}] -> {:ok, nil}
        [{:ok, _}, {:error, error}] -> {:error, inspect(error)}
        [{:error, errors}, {:error, error}] -> {:error, "#{errors}, #{inspect(error)}"}
      end
    end)
  end
end
