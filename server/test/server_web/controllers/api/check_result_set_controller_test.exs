defmodule ServerWeb.Api.CheckResultSetTest do
  use ServerWeb.ConnCase
  alias Server.Factory
  alias Server.Repo

  describe "create with no token or data" do
    test "returns status Bad Request", %{conn: conn} do
      conn = post(conn, check_result_set_path(conn, :create), %{})
      assert json_response(conn, :bad_request)
    end
  end

  describe "create with bad token" do
    test "returns status Unauthorized", %{conn: conn} do
      conn =
        post(conn, check_result_set_path(conn, :create), %{
          "token" => "abcdef",
          "base_branch" => "master",
          "head_sha" => "deadbeef",
          "results" => %{}
        })

      assert json_response(conn, :unauthorized)
    end
  end

  describe "create with valid token, and base / head sha matching PR" do
    setup(%{conn: conn}) do
      repo = Factory.insert(:repository)
      pr = Factory.insert(:pull_request, %{repository: repo})
      check_run = Factory.insert(:check_run, %{pull_request: pr})

      conn =
        post(conn, check_result_set_path(conn, :create), %{
          "token" => repo.auth_token,
          "base_branch" => pr.base_branch,
          "head_sha" => check_run.head_sha,
          "results" => dummy_results()
        })

      %{conn: conn, check_run: check_run}
    end

    test "returns status Created", %{conn: conn} do
      assert json_response(conn, :created)
    end

    test "creates check result set", %{check_run: check_run} do
      assert check_result_set = Repo.one!(Ecto.assoc(check_run, :check_result_set))
      assert check_result_set.status == :new
    end

    test "creates check result for each result received", %{check_run: check_run} do
      check_result_set = Repo.one!(Ecto.assoc(check_run, :check_result_set))
      assert check_results = Repo.all(Ecto.assoc(check_result_set, :check_results))
      assert length(check_results) == 2
    end
  end

  describe "create with valid token, and base / head sha not matching PR" do
    setup(%{conn: conn}) do
      repo = Factory.insert(:repository)
      pr = Factory.insert(:pull_request, %{repository: repo})

      conn =
        post(conn, check_result_set_path(conn, :create), %{
          "token" => repo.auth_token,
          "base_branch" => pr.base_branch,
          "head_sha" => "noonehasthisheadsha",
          "results" => dummy_results()
        })

      %{conn: conn}
    end

    test "returns helpful error message to client, for render", %{conn: conn} do
      assert json_response(conn, :not_found) == %{"error" => "Check Run not found"}
    end

    test "returns status Not Found", %{conn: conn} do
      assert json_response(conn, :not_found)
    end
  end

  defp dummy_results do
    [
      %{
        "name" => "My List",
        "version" => "1",
        "triggers" => %{
          "paths" => ["my/paths/**/*.ex"]
        },
        "list" => []
      },
      %{
        "name" => "My Other List",
        "version" => "1",
        "triggers" => %{
          "paths" => ["different/paths/**/*.ex"]
        },
        "list" => []
      }
    ]
  end
end
