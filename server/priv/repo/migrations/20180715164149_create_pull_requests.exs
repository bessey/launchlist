defmodule Server.Repo.Migrations.CreatePullRequests do
  use Ecto.Migration

  def change do
    create table(:pull_requests) do
      add :pull_request_id, :integer
      add :owner, :string
      add :repo, :string

      timestamps()
    end

  end
end
