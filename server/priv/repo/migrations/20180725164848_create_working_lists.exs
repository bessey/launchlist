defmodule Server.Repo.Migrations.CreateWorkingLists do
  use Ecto.Migration

  def change do
    create table(:working_lists) do
      add(:category, :string)
      add(:head_sha, :string)
      add(:version, :integer)
      add(:status, :integer)
      add(:data, :map)
      add(:pull_request_id, references(:pull_requests, on_delete: :nothing))

      timestamps()
    end

    create(index(:working_lists, [:pull_request_id]))
  end
end
