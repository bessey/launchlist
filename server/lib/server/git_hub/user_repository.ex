defmodule Server.GitHub.UserRepository do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_repositories" do
    belongs_to(:user, Server.Accounts.User)
    belongs_to(:repository, Server.GitHub.Repository)

    timestamps()
  end

  @doc false
  def changeset(user_repository, attrs) do
    user_repository
    |> cast(attrs, [])
    |> assoc_constraint(:user)
    |> assoc_constraint(:repository)
    |> validate_required([])
  end
end
