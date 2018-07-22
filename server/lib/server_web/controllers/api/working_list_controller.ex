defmodule ServerWeb.Api.WorkingListController do
  use ServerWeb, :controller
  alias Server.{Repo, WorkingList, CheckResult, PullRequest}
  require Logger

  def create(conn, %{"data" => data}) do
    # Use token to fetch Repository
    # Use GH API to fetch PR from base / head of that Repo
    pr = Repo.one(PullRequest)

    results = CheckResult.from_result_set(data)

    Enum.map(results, fn result ->
      Map.from_struct(result)
      |> insert_result_into_repo(pr)
    end)

    json(conn, %{status: :ok})
  end

  defp insert_result_into_repo(result = %{"category" => category, "version" => version}, pr) do
    fake_data = %WorkingList{head_sha: "abcdef", status: :new}

    Repo.insert(%WorkingList{
      fake_data
      | pull_request: pr,
        category: category,
        version: version,
        data: result
    })
  end
end
