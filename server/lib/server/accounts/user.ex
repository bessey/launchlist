defmodule Server.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:access_token, :string)
    field(:email, :string)
    field(:github_id, :integer)
    field(:github_username, :string)

    many_to_many(
      :repositories,
      Server.GitHub.Repository,
      join_through: Server.GitHub.UserRepository,
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :github_id, :github_username, :access_token])
    |> validate_required([:github_id, :github_username, :email])
  end
end
