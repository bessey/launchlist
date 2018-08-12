defmodule Server.Factory do
  use ExMachina.Ecto, repo: Server.Repo

  def repository_factory do
    github_id = sequence(:github_id, & &1)
    name = sequence(:github_id, &"repo-#{&1}")
    %Server.GitHub.Repository{github_id: github_id, name: name, auth_token: "#{github_id}"}
  end

  def pull_request_factory do
    github_id = sequence(:github_id, & &1)
    branch_name = sequence(:github_id, &"feature-#{&1}")

    %Server.GitHub.PullRequest{
      github_id: github_id,
      repository: build(:repository),
      base_branch: "master",
      head_branch: branch_name
    }
  end
end
