defmodule ServerWeb.Api.WorkingListController do
  use ServerWeb, :controller
  alias Server.{Repo, WorkingList, CheckResult}
  require Logger

  def create(conn, %{"data" => data}) do
    results = CheckResult.from_result_set(data)

    # TODO actually get this myself

    Enum.map(results, fn result ->
      Map.from_struct(result)
      |> insert_result_into_repo()
    end)

    json(conn, %{status: :ok})
  end

  defp insert_result_into_repo(result = %{"category" => category, "version" => version}) do
    fake_data = %WorkingList{head_sha: "abcdef", status: :new}

    Repo.insert(%WorkingList{
      fake_data
      | category: category,
        version: version,
        data: result
    })
  end
end
