defmodule Server.GitHub.PullRequest do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "pull_requests" do
    field(:github_id, :integer)
    field(:head_branch, :string)
    field(:base_branch, :string)
    belongs_to(:repository, Server.GitHub.Repository)
    has_many(:check_runs, Server.GitHub.CheckRun)

    timestamps()
  end

  @doc false
  def changeset(pull_request, attrs) do
    pull_request
    |> cast(attrs, [:github_id, :repository_id, :head_branch, :base_branch])
    |> assoc_constraint(:repository)
    |> validate_required([:github_id, :head_branch, :base_branch])
  end

  def for_user(query, user) do
    from(
      pr in query,
      join: r in assoc(pr, :repository),
      join: u in assoc(r, :users),
      where: u.id == ^user.id
    )
  end
end
