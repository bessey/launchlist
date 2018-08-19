defmodule Server.GitHub.CheckRun do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "check_runs" do
    field(:head_sha, :string)
    belongs_to(:pull_request, Server.GitHub.PullRequest)
    has_one(:check_result_set, Server.Checker.CheckResultSet)

    timestamps()
  end

  @doc false
  def changeset(check_run, attrs) do
    check_run
    |> cast(attrs, [:head_sha, :pull_request_id])
    |> assoc_constraint(:pull_request)
    |> validate_required([:head_sha, :pull_request_id])
  end
end
