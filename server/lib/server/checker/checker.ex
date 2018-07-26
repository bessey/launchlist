defmodule Server.Checker do
  @moduledoc """
  The Checker context.
  """

  import Ecto.Query, warn: false
  alias Server.Repo

  alias Server.Checker.CheckResultSet

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
end
