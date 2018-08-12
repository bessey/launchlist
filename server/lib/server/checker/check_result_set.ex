defmodule Server.Checker.CheckResultSet do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, except: [cast: 3]

  defenum(StatusEnum, pending: 1, new: 2, in_progress: 3, complete: 4)

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
    |> assoc_constraint(:check_run)
    |> validate_required([:status])
  end
end
