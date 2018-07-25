defmodule Server.Repo.Migrations.CreateCheckResultSets do
  use Ecto.Migration

  def change do
    create table(:check_result_sets) do
      add(:version, :integer, null: false)
      add(:status, :integer, null: false)
      add(:check_run_id, references(:check_runs, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:check_result_sets, [:check_run_id], unique: true))
  end
end
