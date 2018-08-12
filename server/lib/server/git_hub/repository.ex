defmodule Server.GitHub.Repository do
  use Ecto.Schema
  import Ecto.Changeset

  schema "repositories" do
    field(:auth_token, :string)
    field(:name, :string)
    field(:github_id, :integer)
    has_many(:pull_requests, Server.GitHub.PullRequest)
    many_to_many(:users, Server.Accounts.User, join_through: Server.GitHub.UserRepository)

    timestamps()
  end

  @doc false
  def changeset(repository, attrs) do
    repository
    |> cast(attrs, [:auth_token, :name, :github_id])
    |> unique_constraint(:name)
    |> unique_constraint(:github_id)
    |> generate_auth_token_if_empty()
    |> validate_required([:auth_token, :name, :github_id])
  end

  defp generate_auth_token_if_empty(changeset) do
    case get_change(changeset, :auth_token) do
      n when n in [nil, ""] -> put_change(changeset, :auth_token, SecureRandom.base64(32))
      _ -> changeset
    end
  end
end
