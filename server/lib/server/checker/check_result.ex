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
      order_by: fragment("? ->> ? ASC", cr.result, "category")
    )
  end
end
