defmodule Server.GitHub do
  alias Server.GitHub.Repository
  alias Server.Repo

  @moduledoc """
  The GitHub context.
  """

  @doc """
  Creates a repository.

  ## Examples

      iex> create_repository(%{field: value})
      {:ok, %User{}}

      iex> create_repository(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_repository(attrs \\ %{}) do
    %Repository{}
    |> Repository.changeset(attrs)
    |> Repo.insert()
  end

  def delete_repositories(github_ids) do
    Repo.delete_repositories(github_ids)
  end
end
