defmodule Server.Checker.CheckResult do
  use Ecto.Schema
  import Ecto.Changeset

  schema "check_results" do
    field(:category, :string)
    field(:result, :map)
    belongs_to(:check_result_set, Server.Checker.CheckResultSet)

    timestamps()
  end

  @doc false
  def changeset(check_result, attrs) do
    check_result
    |> cast(attrs, [:category, :result])
    |> validate_required([:category, :result, :check_result_set_id])
  end
end
