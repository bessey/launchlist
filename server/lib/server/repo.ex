defmodule Server.Repo do
  use Ecto.Repo, otp_app: :server
  import Ecto.Query
  alias Server.GitHub.{Repository}

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
end
