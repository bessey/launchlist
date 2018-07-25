defmodule Server.Repo.Migrations.CreatePullRequests do
  use Ecto.Migration

  def change do
    create table(:pull_requests) do
      add(:github_id, :integer, null: false)
      add(:repository_id, references(:repositories, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:pull_requests, [:repository_id, :github_id], unique: true))
  end
end
