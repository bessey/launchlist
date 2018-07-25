defmodule Server.GitHubTest do
  use Server.DataCase

  alias Server.GitHub

  describe "repositories" do
    alias Server.GitHub.Repository

    @valid_attrs %{auth_token: "some auth_token", name: "some name"}
    @update_attrs %{auth_token: "some updated auth_token", name: "some updated name"}
    @invalid_attrs %{auth_token: nil, name: nil}

    def repository_fixture(attrs \\ %{}) do
      {:ok, repository} =
        attrs
        |> Enum.into(@valid_attrs)
        |> GitHub.create_repository()

      repository
    end
  end
end
