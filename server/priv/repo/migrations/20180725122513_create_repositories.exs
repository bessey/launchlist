defmodule Server.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add(:auth_token, :string, null: false)
      add(:name, :string, null: false)
      add(:github_id, :integer, null: false)

      timestamps()
    end

    create(index(:repositories, [:auth_token], unique: true))
    create(index(:repositories, [:github_id], unique: true))
    create(index(:repositories, [:name], unique: true))
  end
end
