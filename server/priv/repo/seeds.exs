# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Server.Repo.insert!(%Server.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

repo =
  Server.Repo.insert!(%Server.GitHub.Repository{
    github_id: 123,
    name: "testing",
    auth_token: "abcdef"
  })

Server.Repo.insert!(%Server.GitHub.PullRequest{
  github_id: 123,
  repository_id: repo.id
})
