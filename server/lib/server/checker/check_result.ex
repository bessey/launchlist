defmodule Server.Checker.CheckResult do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "check_results" do
    field(:name, :string)
    field(:result, Server.Checker.Result)
    belongs_to(:check_result_set, Server.Checker.CheckResultSet)

    timestamps()
  end

  @doc false
  def changeset(check_result, attrs) do
    check_result
    |> cast(attrs, [:name, :result, :check_result_set_id])
    |> assoc_constraint(:check_result_set)
    |> validate_required([:name, :result])
  end

  def alphabetical(query \\ Server.Checker.CheckResult) do
    from(
      cr in query,
      order_by: fragment("? ->> ? ASC", cr.result, "name")
    )
  end

  def for_user(query, user) do
    from(
      cr in query,
      join: crs in assoc(cr, :check_result_set),
      join: crun in assoc(crs, :check_run),
      join: pr in assoc(crun, :pull_request),
      join: r in assoc(pr, :repository),
      join: u in assoc(r, :users),
      where: u.id == ^user.id
    )
  end

  def for_pull_request(query, pr_id) do
    from(
      [cr, crs, crun] in query,
      where: crun.pull_request_id == ^pr_id
    )
  end
end
