defmodule Server.Repo do
  use Ecto.Repo, otp_app: :server
  import Ecto.Query
  alias Server.GitHub.{Repository, CheckRun}

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  def delete_repositories(github_ids) do
    from(r in Repository, where: r.github_id in ^github_ids)
    |> delete_all()
  end

  def get_check_run_from_github_ids(repo_github_id, pull_request_github_id) do
    from(
      c in CheckRun,
      join: p in assoc(c, :pull_request),
      join: r = assoc(p, :repository),
      where: r.github_id == ^repo_github_id && p.github_id == ^pull_request_github_id
    )
    |> Repo.all()
  end
end
