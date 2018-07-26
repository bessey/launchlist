defmodule Server.GitHub do
  alias Server.GitHub.{Repository, PullRequest, CheckRun, ApiClient}
  alias Server.Repo

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

  def upsert_check_run_from_github!(pull_request_github_id, %{head_sha: head_sha} = attrs) do
    pull_request = Repo.get_by!(PullRequest, github_id: pull_request_github_id)

    if check_run = Repo.get_by(pull_request.assoc(:check_runs), head_sha: head_sha) do
      check_run
    else
      pull_request.build_assoc(:check_runs)
      |> CheckRun.changeset(attrs)
      |> Repo.insert_or_update!()
    end
  end

  def send_pending_check_run(%CheckRun{} = check_run) do
    ApiClient.send_pending_check_run(%{
      head_sha: check_run.head_sha,
      external_id: check_run.id,
      status: "queued",
      started_at: check_run.inserted_at
    })
  end
end
