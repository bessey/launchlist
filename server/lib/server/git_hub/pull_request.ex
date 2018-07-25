defmodule Server.GitHub.PullRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pull_requests" do
    field(:github_id, :integer)
    field(:repository_id, :id)

    timestamps()
  end

  @doc false
  def changeset(pull_request, attrs) do
    pull_request
    |> cast(attrs, [:github_id, :repository_id])
    |> validate_required([:github_id, :repository_id])
  end
end