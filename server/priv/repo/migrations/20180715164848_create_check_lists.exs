defmodule Server.Repo.Migrations.CreateCheckLists do
  use Ecto.Migration

  def change do
    create table(:check_lists) do
      add :head_sha, :string
      add :status, :integer
      add :data, :map
      add :pull_request_id, references(:pull_requests, on_delete: :nothing)

      timestamps()
    end

    create index(:check_lists, [:pull_request_id])
  end
end
