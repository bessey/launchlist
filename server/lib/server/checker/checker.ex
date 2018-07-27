defmodule Server.Checker do
  alias Server.Checker.Parser

  @moduledoc """
  The Checker context.
  """

  import Ecto.Query, warn: false
  alias Server.Repo

  alias Server.Checker.{CheckResultSet, CheckResult}

  @doc """
  Creates a check_result_set.

  ## Examples

      iex> create_check_result_set(%{field: value})
      {:ok, %CheckResultSet{}}

      iex> create_check_result_set(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_check_result_set(attrs \\ %{}) do
    %CheckResultSet{}
    |> CheckResultSet.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a check_result.

  ## Examples

      iex> create_check_result(%{field: value})
      {:ok, %CheckResult{}}

      iex> create_check_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_check_result(attrs \\ %{}) do
    %CheckResult{}
    |> CheckResult.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
    Convert untyped map to nested structs
  """
  @spec parse_result_set(map) :: %Parser.ResultSet{}
  def parse_result_set(%{} = data) do
    results = Enum.map(data, &Parser.parse_single_result/1)
    version = List.first(results).version
    %Parser.ResultSet{results: results, version: version}
  end
end
