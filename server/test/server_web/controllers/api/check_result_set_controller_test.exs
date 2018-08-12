defmodule ServerWeb.Api.CheckResultSetTest do
  use ServerWeb.ConnCase

  alias Server.Repo
  alias Server.GitHub.{Repository}
  alias Server.Checker.{CheckResultSet}

  describe "create with no token or data" do
    test "returns status Bad Request", %{conn: conn} do
      conn = post(conn, check_result_set_path(conn, :create), %{})
      assert json_response(conn, :bad_request)
    end
  end

  describe "create with bad token" do
    test "returns status Unauthorized", %{conn: conn} do
      conn =
        post(conn, check_result_set_path(conn, :create), %{"token" => "abcdef", "results" => %{}})

      assert json_response(conn, :unauthorized)
    end
  end

  describe "create with valid token, and base / head sha matching PR" do
    setup(%{conn: conn}) do
      token =
        Repo.insert!(%Repository{name: "tester", auth_token: "deadbeef", github_id: 123}).auth_token

      results = [
        %{
          "name" => "My List",
          "version" => "1",
          "triggers" => %{
            "paths" => ["my/paths/**/*.ex"]
          },
          "list" => []
        }
      ]

      conn =
        post(conn, check_result_set_path(conn, :create), %{"token" => token, "results" => results})

      %{conn: conn}
    end

    test "returns status Created", %{conn: conn} do
      assert json_response(conn, :created)
    end

    test "creates check result set", %{conn: conn} do
    end

    test "creates check result for each result received"
  end

  describe "create with valid token, and base / head sha not matching PR" do
    test "returns helpful error message to client, for render"
    test "returns status Not Acceptable"
  end
end
