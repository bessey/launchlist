defmodule Server.Repo.Migrations.CreateRepositories do
  use Ecto.Migration

  def change do
    create table(:repositories) do
      add :auth_token, :string
      add :name, :string

      timestamps()
    end

  end
end
