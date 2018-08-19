defmodule Server.Checker.Result do
  @behaviour Ecto.Type
  def type, do: :map

  # Accept casting of URI structs as well
  def cast(%Server.Checker.Parser.Result{} = result), do: {:ok, result}

  # Everything else is a failure though
  def cast(_), do: :error

  # When loading data from the database, we are guaranteed to
  # receive a map (as databases are strict) and we will
  # just put the data back into an URI struct to be stored
  # in the loaded schema struct.
  def load(data) when is_map(data) do
    {:ok, Server.Checker.Parser.parse_single_result(data)}
  end

  # When dumping data to the database, we *expect* an URI struct
  # but any value could be inserted into the schema struct at runtime,
  # so we need to guard against them.
  def dump(%Server.Checker.Parser.Result{} = result) do
    {:ok, Map.from_struct(result)}
  end

  def dump(_), do: :error
end
