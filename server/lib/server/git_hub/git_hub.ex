defmodule Server.GitHub do
  alias Server.GitHub.{Repository, PullRequest, CheckRun, ApiClient}
  alias Server.Repo
  import Ecto.Query

  def delete_repositories_from_github(github_ids) do
    Repo.delete_repositories(github_ids)
  end

  def upsert_repo_from_github(repo_github_id, attrs) do
    case Repo.get_by(Repository, github_id: repo_github_id) do
      nil ->
        %Repository{github_id: repo_github_id}

      repo ->
        repo
    end
    |> Repository.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def upsert_pull_request_from_github(pr_github_id, attrs) do
    case Repo.get_by(PullRequest, github_id: pr_github_id) do
      nil ->
        %PullRequest{github_id: pr_github_id}

      pull_request ->
        pull_request
    end
    |> PullRequest.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def send_queued_check_run(pr_github_id, head_sha, owner_name) do
    {pull_request, check_run} = upsert_check_run_from_github!(pr_github_id, %{head_sha: head_sha})

    repo =
      from(
        r in Repository,
        join: p in assoc(r, :pull_requests),
        select: r.name,
        where: p.id == ^pull_request.id
      )
      |> Server.Repo.one()

    ApiClient.send_check_run(
      owner_name,
      repo.name,
      %{
        head_sha: check_run.head_sha,
        external_id: check_run.id,
        status: "queued",
        started_at: check_run.inserted_at
      }
    )
  end

  @spec upsert_check_run_from_github!(String.t(), map) :: CheckRun | {PullRequest, CheckRun}
  defp upsert_check_run_from_github!(pr_github_id, %{head_sha: head_sha} = attrs) do
    pull_request = Repo.get_by!(PullRequest, github_id: pr_github_id)

    check_run =
      case Repo.get_by(pull_request.assoc(:check_runs), head_sha: head_sha) do
        nil ->
          pull_request.build_assoc(:check_runs)
          |> CheckRun.changeset(attrs)
          |> Repo.insert_or_update!()

        check_run ->
          check_run
      end

    {pull_request, check_run}
  end
end
