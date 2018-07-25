defmodule Server.Repo.Migrations.CreateCheckRuns do
  use Ecto.Migration

  def change do
    create table(:check_runs) do
      add(:head_sha, :string, null: false)
      add(:pull_request_id, references(:pull_requests, on_delete: :nothing), null: false)

      timestamps()
    end

    create(index(:check_runs, [:pull_request_id, :head_sha], unique: true))
  end
end
