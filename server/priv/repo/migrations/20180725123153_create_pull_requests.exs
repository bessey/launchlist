defmodule Server.Repo.Migrations.CreatePullRequests do
  use Ecto.Migration

  def change do
    create table(:pull_requests) do
      add :github_id, :integer
      add :repository_id, references(:repositories, on_delete: :nothing)

      timestamps()
    end

    create index(:pull_requests, [:repository_id])
  end
end
