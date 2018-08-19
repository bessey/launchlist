defmodule Server.Factory do
  use ExMachina.Ecto, repo: Server.Repo
  alias Server.Checker.Parser

  def user_factory do
    id = sequence(:user, & &1)

    %Server.Accounts.User{
      email: "user-#{id}@gmail.com",
      github_id: to_string(id),
      github_username: "user-#{id}"
    }
  end

  def repository_factory do
    github_id = sequence(:repository, & &1)
    name = sequence(:repository, &"repo-#{&1}")

    %Server.GitHub.Repository{
      github_id: github_id,
      name: "repo-man/#{name}",
      auth_token: "#{github_id}"
    }
  end

  def pull_request_factory do
    id = sequence(:pull_request, & &1)

    %Server.GitHub.PullRequest{
      github_id: id,
      repository: build(:repository),
      base_branch: "master",
      head_branch: "feature-#{id}"
    }
  end

  def check_run_factory do
    head_sha = sequence(:check_run, &"abcd#{&1}")

    %Server.GitHub.CheckRun{
      head_sha: head_sha,
      pull_request: build(:pull_request)
    }
  end

  def check_result_set_factory do
    %Server.Checker.CheckResultSet{
      version: 1,
      status: :pending,
      check_run: build(:check_run)
    }
  end

  def check_result_factory do
    id = sequence(:check_result, & &1)

    %Server.Checker.CheckResult{
      name: "My Result ##{id}",
      check_result_set: build(:check_result_set),
      result: %Parser.Result{
        version: 1,
        name: "My Result ##{id}",
        triggers: %Parser.TriggerSet{paths: "test"},
        list: [
          %Parser.CheckSet{
            category: "First Thing",
            triggers: %Parser.TriggerSet{paths: "test/me"},
            checks: [
              %Parser.Check{
                check: "Confirm the thing is a thing, and not a different thing",
                set: true,
                triggers: %Parser.TriggerSet{
                  paths: [
                    "test/me/out"
                  ]
                }
              }
            ]
          },
          %Parser.CheckSet{
            category: "Last Thing",
            triggers: %Parser.TriggerSet{paths: "test/me"},
            checks: [
              %Parser.Check{
                check: "Confirm the thing is a thing, and not a different thing",
                set: false,
                triggers: %Parser.TriggerSet{
                  paths: [
                    "test/me/out"
                  ]
                }
              }
            ]
          }
        ]
      }
    }
  end
end
