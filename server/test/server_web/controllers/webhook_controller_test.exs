defmodule ServerWeb.WebhookControllerTest do
  use ServerWeb.ConnCase, async: true

  alias Server.Repo
  alias Server.GitHub.{CheckRun, PullRequest, Repository}
  alias Server.Checker.{CheckResultSet}

  import Tesla.Mock

  setup(%{conn: conn}) do
    %{conn: put_req_header(conn, "x-github-delivery", "abcdef")}
  end

  describe "create, Payload: check_suite, Action: requested" do
    setup [:mock_github_check_run_call]

    test "creates a placeholder check run associated with the check suite", %{conn: conn} do
      check_suite_requested_webhook = %{
        "action" => "requested",
        "repository" => %{
          "id" => 321,
          "name" => "my-repo",
          "owner" => %{
            "login" => "person"
          }
        },
        "check_suite" => %{
          "head_sha" => "deadbeef",
          "pull_requests" => [
            %{
              "id" => 123
            }
          ]
        }
      }

      conn =
        conn
        |> put_req_header("x-github-event", "check_suite")
        |> post(webhook_path(conn, :create), check_suite_requested_webhook)

      assert json_response(conn, :accepted)

      assert %{
               name: "my-repo",
               github_id: 321
             } = Repo.get_by!(Repository, github_id: 321)

      pr = Repo.get_by!(PullRequest, github_id: 123)
      check_run = Repo.get_by!(CheckRun, pull_request_id: pr.id)

      assert %{head_sha: "deadbeef"} = check_run
      assert %{status: :new} = Repo.get_by!(CheckResultSet, check_run_id: check_run.id)
    end
  end

  describe "create, Payload: installation_repositories, Action: added" do
    setup(%{conn: conn}) do
      %{conn: put_req_header(conn, "x-github-event", "installation_repositories")}
    end

    test "creates repositories for each installation", %{conn: conn} do
      conn =
        conn
        |> post(webhook_path(conn, :create), %{
          "action" => "added",
          "repositories_added" => [
            %{
              "id" => 123,
              "name" => "one-repo"
            },
            %{
              "id" => 321,
              "name" => "another-repo"
            }
          ]
        })

      assert json_response(conn, :created)
      assert %{name: "one-repo"} = Repo.get_by!(Repository, github_id: 123)
      assert %{name: "another-repo"} = Repo.get_by!(Repository, github_id: 321)
    end

    test "updates existing repositories with new data", %{conn: conn} do
      Repo.insert!(%Repository{github_id: 123, name: "old-name", auth_token: "test"})

      conn =
        conn
        |> post(webhook_path(conn, :create), %{
          "action" => "added",
          "repositories_added" => [
            %{
              "id" => 123,
              "name" => "renamed-repo"
            }
          ]
        })

      assert json_response(conn, :created)
      assert %{name: "renamed-repo"} = Repo.get_by!(Repository, github_id: 123)
    end
  end

  describe "create, Payload: installation_repositories, Action: removed" do
    setup(%{conn: conn}) do
      %{conn: put_req_header(conn, "x-github-event", "installation_repositories")}
    end

    test "destroys repositories for each uninstall", %{conn: conn} do
      Repo.insert!(%Repository{github_id: 123, name: "to-die", auth_token: "test"})

      conn =
        conn
        |> post(webhook_path(conn, :create), %{
          "action" => "removed",
          "repositories_removed" => [
            %{
              "id" => 123
            }
          ]
        })

      assert json_response(conn, :accepted)
      refute Repo.get_by(Repository, github_id: 123)
    end

    test "doesnt crash when repo already doesnt exist", %{conn: conn} do
      conn =
        conn
        |> post(webhook_path(conn, :create), %{
          "action" => "removed",
          "repositories_removed" => [
            %{
              "id" => 123
            }
          ]
        })

      assert json_response(conn, :accepted)
      refute Repo.get_by(Repository, github_id: 123)
    end
  end

  describe "create, Payload: pull_request, Action: opened" do
    setup(%{conn: conn}) do
      %{conn: put_req_header(conn, "x-github-event", "pull_request")}
    end

    test "creates a matching pull request + repository record", %{conn: conn} do
      conn =
        conn
        |> post(webhook_path(conn, :create), %{
          "action" => "opened",
          "repository" => %{
            "id" => 123,
            "name" => "my-repo"
          },
          "pull_request" => %{
            "id" => 321
          }
        })

      assert json_response(conn, :created)

      repo = Repo.get_by!(Repository, github_id: 123, name: "my-repo")
      assert Repo.get_by(PullRequest, github_id: 321, repository_id: repo.id)
    end

    test "updates existing pull request + repository record", %{conn: conn} do
      repo = Repo.insert!(%Repository{github_id: 123, name: "existing", auth_token: "1234"})
      Repo.insert!(%PullRequest{github_id: 321, repository_id: repo.id})

      conn =
        conn
        |> post(webhook_path(conn, :create), %{
          "action" => "opened",
          "repository" => %{
            "id" => 123,
            "name" => "my-repo"
          },
          "pull_request" => %{
            "id" => 321
          }
        })

      assert json_response(conn, :created)

      repo = Repo.get_by!(Repository, github_id: 123, name: "my-repo", id: repo.id)
      assert Repo.get_by(PullRequest, github_id: 321, repository_id: repo.id)
    end
  end

  defp mock_github_check_run_call(_context) do
    mock(fn
      %{
        method: :post,
        headers: [
          {"content-type", "application/json"},
          {"accept", "application/vnd.github.v3+json"}
        ]
      } ->
        json(%{"id" => 4})
    end)

    :ok
  end
end
