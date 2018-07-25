defmodule Server.Repo.Migrations.CreateCheckResults do
  use Ecto.Migration

  def change do
    create table(:check_results) do
      add(:category, :string, null: false)
      add(:result, :map, null: false)

      add(
        :check_result_set_id,
        references(:check_result_sets, on_delete: :delete_all),
        null: false
      )

      timestamps()
    end

    create(index(:check_results, [:check_result_set_id]))
  end
end
