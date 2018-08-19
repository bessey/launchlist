defmodule Server.Checker.Parser do
  defmodule TriggerSet do
    @enforce_keys [:paths]
    defstruct [:paths]
  end

  defmodule Check do
    @enforce_keys [:check, :set]
    defstruct [:check, :triggers, :set]
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
    %Result{
      name: result["name"],
      version: result["version"],
      triggers: parse_trigger_set(result["triggers"]),
      list: Enum.map(result["list"], &parse_check_set/1)
    }
  end

  @spec status_for_result_set(%ResultSet{}) :: :new | :in_progress | :complete
  def status_for_result_set(result_set) do
    Enum.map(result_set.check_results, fn check_result -> check_result.result end)
    |> Enum.reduce(:new, fn result, acc ->
      [acc, status_for_result(result)]
      |> Enum.sort()
      |> case do
        [:in_progress, _] ->
          :in_progress

        [_, :in_progress] ->
          :in_progress

        [:complete, :new] ->
          :in_progress

        # Wether its two new, or two complete, the product is the same
        [status, status] ->
          status
      end
    end)
  end

  @spec status_for_result(%Result{}) :: :new | :in_progress | :complete
  def status_for_result(result) do
    Enum.flat_map(result.list, fn check_set ->
      check_set.checks
    end)
    |> status_reduce()
  end

  @spec parse_check_set(map) :: %CheckSet{}
  defp parse_check_set(%{} = check_set) do
    %CheckSet{
      category: check_set["category"],
      checks: Enum.map(check_set["checks"], &parse_check/1)
    }
  end

  @spec parse_check(map) :: %Check{}
  defp parse_check(%{} = check) do
    %Check{
      check: check["check"],
      triggers: parse_trigger_set(check["triggers"]),
      set: check["set"] || false
    }
  end

  @spec parse_trigger_set(map) :: %TriggerSet{}
  defp parse_trigger_set(%{} = trigger_set) do
    %TriggerSet{paths: trigger_set["paths"]}
  end

  defp status_reduce(checks) do
    count = %{
      yes: Enum.count(checks, fn check -> check.set end),
      no: Enum.count(checks, fn check -> !check.set end)
    }

    case count do
      %{yes: 0, no: 0} -> throw("Bad things happening")
      %{yes: 0, no: _} -> :new
      %{yes: _, no: 0} -> :complete
      %{yes: _, no: _} -> :in_progress
    end
  end
end
