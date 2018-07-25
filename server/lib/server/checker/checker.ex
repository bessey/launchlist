defmodule Server.Checker do
  @moduledoc """
  The Checker context.
  """

  import Ecto.Query, warn: false
  alias Server.Repo

  alias Server.Checker.CheckResultSet

  @doc """
  Returns the list of check_result_sets.

  ## Examples

      iex> list_check_result_sets()
      [%CheckResultSet{}, ...]

  """
  def list_check_result_sets do
    Repo.all(CheckResultSet)
  end

  @doc """
  Gets a single check_result_set.

  Raises `Ecto.NoResultsError` if the Check result set does not exist.

  ## Examples

      iex> get_check_result_set!(123)
      %CheckResultSet{}

      iex> get_check_result_set!(456)
      ** (Ecto.NoResultsError)

  """
  def get_check_result_set!(id), do: Repo.get!(CheckResultSet, id)

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
  Updates a check_result_set.

  ## Examples

      iex> update_check_result_set(check_result_set, %{field: new_value})
      {:ok, %CheckResultSet{}}

      iex> update_check_result_set(check_result_set, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_check_result_set(%CheckResultSet{} = check_result_set, attrs) do
    check_result_set
    |> CheckResultSet.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CheckResultSet.

  ## Examples

      iex> delete_check_result_set(check_result_set)
      {:ok, %CheckResultSet{}}

      iex> delete_check_result_set(check_result_set)
      {:error, %Ecto.Changeset{}}

  """
  def delete_check_result_set(%CheckResultSet{} = check_result_set) do
    Repo.delete(check_result_set)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking check_result_set changes.

  ## Examples

      iex> change_check_result_set(check_result_set)
      %Ecto.Changeset{source: %CheckResultSet{}}

  """
  def change_check_result_set(%CheckResultSet{} = check_result_set) do
    CheckResultSet.changeset(check_result_set, %{})
  end
end
