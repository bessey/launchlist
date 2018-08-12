defmodule Server.Repo.Migrations.CreateUsersRepositories do
  use Ecto.Migration

  def change do
    create table(:users_repositories) do
      add :user_id, references(:users, on_delete: :nothing)
      add :repository_id, references(:repositories, on_delete: :nothing)

      timestamps()
    end

    create index(:users_repositories, [:user_id])
    create index(:users_repositories, [:repository_id])
  end
end
