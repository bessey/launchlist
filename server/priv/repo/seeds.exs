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

Code.require_file("../../test/support/factory.ex", __DIR__)

alias Server.Factory

user =
  Factory.insert(:user, %{
    github_username: "bessey",
    email: "bessey@gmail.com",
    github_id: 708_200
  })

repo =
  Factory.insert(:repository, %{
    name: "bessey/bessey.github.io",
    github_id: 10_909_540,
    users: [user]
  })

pull_request = Factory.insert(:pull_request, %{repository: repo})

check_run = Factory.insert(:check_run, %{pull_request: pull_request})

check_result_set = Factory.insert(:check_result_set, %{check_run: check_run})

Factory.insert_list(3, :check_result, %{check_result_set: check_result_set})
