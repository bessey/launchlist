defmodule Server.GitHub do
  alias Server.GitHub.Repository
  alias Server.GitHub.PullRequest
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

      repo ->
        repo
    end
    |> PullRequest.changeset(attrs)
    |> Repo.insert_or_update()
  end
end
