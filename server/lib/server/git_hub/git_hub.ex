defmodule Server.GitHub do
  alias Server.GitHub.{Repository, PullRequest, CheckRun, ApiClient}
  alias Server.Repo
  import Ecto.Query
  import Ecto

  def delete_repositories_from_github(github_ids) do
    Repo.delete_repositories(github_ids)
  end

  def get_repository_by_token(token) do
    Repo.get_by(Repository, token: token)
  end

  def upsert_repo_from_github(repo_github_id, %{} = attrs) do
    case Repo.get_by(Repository, github_id: repo_github_id) do
      nil -> %Repository{github_id: repo_github_id}
      repo -> repo
    end
    |> Repository.changeset(attrs)
    |> Repo.insert_or_update()
  end

  def upsert_pull_request_from_github(pr_github_id, %{} = attrs) do
    case Repo.get_by(PullRequest, github_id: pr_github_id) do
      nil -> %PullRequest{}
      pull_request -> pull_request
    end
    |> PullRequest.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @spec upsert_check_run_from_github!(integer, map) :: {%PullRequest{}, %CheckRun{}}
  def upsert_check_run_from_github!(pr_github_id, %{head_sha: head_sha} = attrs) do
    pull_request =
      from(
        p in PullRequest,
        where: p.github_id == ^pr_github_id,
        limit: 1
      )
      |> Repo.one!()

    check_run =
      from(
        c in assoc(pull_request, :check_runs),
        where: c.head_sha == ^head_sha,
        limit: 1
      )
      |> Repo.one()

    check_run =
      case check_run do
        nil ->
          pull_request
          |> build_assoc(:check_runs)
          |> CheckRun.changeset(attrs)
          |> Repo.insert_or_update!()

        check_run ->
          check_run
      end

    {pull_request, check_run}
  end

  ### API CLIENT

  @spec send_queued_check_run(String.t(), %PullRequest{}, %CheckRun{}, map) :: any
  def send_queued_check_run(owner_name, pull_request, check_run, %{id: external_id}) do
    repo_name =
      from(
        r in Repository,
        join: p in assoc(r, :pull_requests),
        select: r.name,
        where: p.id == ^pull_request.id
      )
      |> Server.Repo.one()

    ApiClient.send_check_run(
      owner_name,
      repo_name,
      %{
        head_sha: check_run.head_sha,
        external_id: external_id,
        status: "queued",
        started_at: check_run.inserted_at
      }
    )
  end
end
