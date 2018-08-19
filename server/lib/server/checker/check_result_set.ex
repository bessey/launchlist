defmodule Server.Checker.CheckResultSet do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, except: [cast: 3]
  import Ecto.Query

  defenum(StatusEnum, pending: 1, new: 2, in_progress: 3, complete: 4)

  schema "check_result_sets" do
    field(:status, StatusEnum, default: :new)
    field(:version, :integer)
    belongs_to(:check_run, Server.GitHub.CheckRun)
    has_many(:check_results, Server.Checker.CheckResult)

    timestamps()
  end

  def for_user(query, user) do
    from(
      crs in query,
      join: cr in assoc(crs, :check_run),
      join: pr in assoc(cr, :pull_request),
      join: r in assoc(pr, :repository),
      join: u in assoc(r, :users),
      where: u.id == ^user.id
    )
  end

  def for_pull_request(query, pr_id) do
    from(
      [crs, cr] in query,
      where: cr.pull_request_id == ^pr_id
    )
  end

  @doc false
  def changeset(check_result_set, attrs) do
    check_result_set
    |> cast(attrs, [:version, :status, :check_run_id])
    |> assoc_constraint(:check_run)
    |> validate_required([:status])
  end
end
