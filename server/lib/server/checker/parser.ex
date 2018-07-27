defmodule Server.Checker.Parser do
  defmodule TriggerSet do
    @enforce_keys [:paths]
    defstruct [:paths]
  end

  defmodule Check do
    @enforce_keys [:check]
    defstruct [:check, :triggers]
  end

  defmodule CheckSet do
    @enforce_keys [:category, :checks]
    defstruct [:category, :checks, :triggers]
  end

  defmodule Result do
    @enforce_keys [:name, :version, :list]
    defstruct [:name, :version, :triggers, :list]
  end

  defmodule ResultSet do
    @enforce_keys [:results, :version]
    defstruct [:results, :version]
  end

  @spec parse_single_result(map) :: %Result{}
  def parse_single_result(%{} = result) do
    struct!(Root, %{
      name: result["name"],
      version: result["version"],
      triggers: parse_trigger_set(result["triggers"]),
      list: Enum.map(result["list"], &parse_check_set/1)
    })
  end

  @spec parse_check_set(map) :: %CheckSet{}
  defp parse_check_set(%{} = check_set) do
    struct!(CheckSet, %{
      category: check_set["category"],
      checks: Enum.map(check_set["checks"], &parse_check/1)
    })
  end

  @spec parse_check(map) :: %Check{}
  defp parse_check(%{} = check) do
    struct(Check, %{
      check: check["check"],
      triggers: parse_trigger_set(check["trigger_set"])
    })
  end

  @spec parse_trigger_set(map) :: %TriggerSet{}
  defp parse_trigger_set(%{} = trigger_set) do
    struct!(TriggerSet, %{paths: trigger_set["paths"]})
  end
end
