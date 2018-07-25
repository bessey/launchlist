defmodule Server.Checker.CheckResultSet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "check_result_sets" do
    field(:status, :integer)
    field(:version, :integer)
    belongs_to(:check_run, Server.GitHub.CheckRun)
    has_many(:check_results, Server.Checker.CheckResult)

    timestamps()
  end

  @doc false
  def changeset(check_result_set, attrs) do
    check_result_set
    |> cast(attrs, [:version, :status])
    |> validate_required([:version, :status, :check_run_id])
  end
end
