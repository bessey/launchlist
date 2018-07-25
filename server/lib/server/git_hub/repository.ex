defmodule Server.GitHub.Repository do
  use Ecto.Schema
  import Ecto.Changeset

  schema "repositories" do
    field(:auth_token, :string)
    field(:name, :string)
    field(:github_id, :integer)

    timestamps()
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [:auth_token, :name, :github_id])
    |> validate_required([:auth_token, :name, :github_id])
  end
end
