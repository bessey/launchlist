defmodule Server.GitHub.PullRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pull_requests" do
    field(:github_id, :integer)
    belongs_to(:repository, Server.GitHub.Repository)
    has_many(:check_runs, Server.GitHub.CheckRun)

    timestamps()
  end

  @doc false
  def changeset(pull_request, attrs) do
    pull_request
    |> cast(attrs, [:github_id, :repository_id])
    |> assoc_constraint(:repository)
    |> validate_required([:github_id])
  end
end
