defmodule Server.Checker.CheckResultSet do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, except: [cast: 3]

  defenum(StatusEnum, new: 1, in_progress: 2, complete: 3)

  schema "check_result_sets" do
    field(:status, StatusEnum, default: :new)
    field(:version, :integer)
    belongs_to(:check_run, Server.GitHub.CheckRun)
    has_many(:check_results, Server.Checker.CheckResult)

    timestamps()
  end

  @doc false
  def changeset(check_result_set, attrs) do
    check_result_set
    |> cast(attrs, [:version, :status, :check_run_id])
    |> validate_required([:status, :check_run_id])
  end
end
