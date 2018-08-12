defmodule Server.GitHub do
  alias Server.GitHub.{Repository, PullRequest, CheckRun, ApiClient}
  alias Server.Repo
  import Ecto.Query
  import Ecto

  def delete_repositories_from_github(github_ids) do
    Repo.delete_repositories(github_ids)
  end

  def get_repository_by_token(token) do
    Repo.get_by(Repository, auth_token: token)
  end

  def get_check_run_by_refs(base_branch, head_sha) do
    from(
      cr in CheckRun,
      join: pr in assoc(cr, :pull_request),
      where: pr.base_branch == ^base_branch and cr.head_sha == ^head_sha
    )
    |> Repo.one()
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
      nil -> %PullRequest{github_id: pr_github_id}
      pull_request -> pull_request
    end
    |> PullRequest.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @spec upsert_check_run_from_github(%PullRequest{}, %{head_sha: any()}) ::
          {:ok, any()} | {:error, any()}
  def upsert_check_run_from_github(pull_request, %{head_sha: head_sha} = attrs) do
    check_run =
      from(
        c in assoc(pull_request, :check_runs),
        where: c.head_sha == ^head_sha,
        limit: 1
      )
      |> Repo.one()

    case check_run do
      nil ->
        pull_request
        |> build_assoc(:check_runs)
        |> CheckRun.changeset(attrs)
        |> Repo.insert_or_update()

      check_run ->
        {:ok, check_run}
    end
  end

  ### API CLIENT

  @spec update_repositories_for_user(Server.Accounts.User.t()) :: {:ok, any()} | {:error, any()}
  def update_repositories_for_user(user) do
    client = ApiClient.rest_client(user.access_token)

    repos =
      Tentacat.Repositories.list_mine(client)
      |> Enum.map(&Server.GitHub.upsert_repo_from_github(&1["id"], %{name: &1["full_name"]}))
      |> Enum.map(&elem(&1, 1))

    user
    |> Repo.preload(:repositories)
    |> Server.Accounts.change_user()
    |> Ecto.Changeset.put_assoc(:repositories, repos)
    |> Repo.update()
  end

  @spec send_queued_check_run(%PullRequest{}, %CheckRun{}, map) ::
          {:error, any()} | {:ok, Tesla.Env.t()}
  def send_queued_check_run(pull_request, check_run, %{id: external_id}) do
    repo_name =
      from(
        r in Repository,
        join: p in assoc(r, :pull_requests),
        select: r.name,
        where: p.id == ^pull_request.id
      )
      |> Server.Repo.one()

    ApiClient.send_check_run(
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
