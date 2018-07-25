defmodule Server.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string)
      add(:access_token, :string)
      add(:github_id, :integer)
      add(:github_username, :string)

      timestamps()
    end
  end
end
