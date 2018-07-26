defmodule ServerWeb.Api.GitHub.WebhookController do
  use ServerWeb, :controller
  require Logger
  alias Server.GitHub

  plug(GitHubWebhookHeaders)

  def create(%{assigns: %{github_event: event}} = conn, payload) do
    Logger.debug("Processing Event: '#{event}'")
    response = process_event(event, payload)
    json(conn, response)
  end

  defp process_event("check_suite", %{"action" => "requested"} = payload),
    do: check_suite_requested(payload)

  defp process_event("check_suite", %{"action" => "rerequested"} = payload),
    do: check_suite_requested(payload)

  defp process_event("installation", _) do
    Logger.info("Hey someone installed it")
    %{status: :ok}
  end

  defp process_event("installation_repositories", %{"action" => "added"} = payload) do
    Logger.info("Adding #{length(payload["repositories_added"])} Repos")

    Enum.each(payload["repositories_added"], fn repo ->
      GitHub.upsert_repo_from_github(repo["id"], %{name: repo["name"]})
    end)

    %{status: :created}
  end

  defp process_event("installation_repositories", %{"action" => "removed"} = payload) do
    Logger.info("Deleting #{length(payload["repositories_removed"])} Repos")

    Enum.map(payload["repositories_removed"], fn repo -> repo["id"] end)
    |> GitHub.delete_repositories_from_github()

    %{status: :accepted}
  end

  defp process_event("pull_request", %{"action" => "opened"} = payload) do
    repository_attrs = %{name: payload["repository"]["name"]}

    with {:ok, repo} <-
           GitHub.upsert_repo_from_github(payload["repository"]["id"], repository_attrs),
         {:ok, _} <-
           GitHub.upsert_pull_request_from_github(payload["number"], %{repository_id: repo.id}) do
      %{status: :created}
    else
      error -> %{status: :error, error: inspect(error)}
    end
  end

  defp process_event(event, _) do
    Logger.debug("Unhandled Event #{event}")
    %{status: :ok}
  end

  defp check_suite_requested(payload) do
    Logger.info("Check Suite Requested")

    Enum.each(payload["check_suite"]["pull_requests"], fn pr ->
      GitHub.send_queued_check_run(
        pr["id"],
        payload["check_suit"]["head_sha"],
        payload["repository"]["owner"]["login"]
      )
    end)

    %{status: :accepted}
  end
end
