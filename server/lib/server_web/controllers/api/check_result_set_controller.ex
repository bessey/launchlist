defmodule ServerWeb.Api.CheckResultSetController do
  use ServerWeb, :controller
  alias Server.{Checker, GitHub, Repo}
  require Logger

  @doc """
    The official public API endpoint for posting CLI results
  """
  def create(conn, %{"token" => token, "results" => data}) do
    case GitHub.get_repository_by_token(token) do
      nil ->
        put_status(conn, :unauthorized)

      repo ->
        Logger.info("New check result set for Repo #{repo.id} (#{repo.name})")
        result_set = Checker.parse_result_set(data)

        trans =
          Repo.transaction(fn ->
            check_result_set = Checker.create_check_result_set(%{version: result_set.version})

            Enum.map(result_set.results, fn result ->
              create_check_result(check_result_set, result)
            end)
          end)

        case trans do
          {:ok, _} -> conn |> put_status(:created) |> json(:ok)
          {:error, data} -> conn |> put_status(:not_acceptable) |> json(%{error: data})
        end
    end
  end

  defp create_check_result(check_result_set, %Checker.Parser.Result{} = result) do
    attrs = %{
      name: result.name,
      version: result.version,
      data: result
    }

    check_result_set
    |> Ecto.build_assoc(:check_result, attrs)
    |> Map.from_struct()
    |> Checker.create_check_result()
  end
end
