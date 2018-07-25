defmodule ServerWeb.Api.GitHub.WebhookController do
  use ServerWeb, :controller
  require Logger
  alias Server.GitHub

  plug(GitHubWebhookHeaders)

  def create(%{assigns: %{github_event: event}} = conn, payload) do
    status =
      case event do
        "installation" ->
          Logger.info("Hey someone installed it")
          :ok

        "installation_repositories" ->
          repo_install_event(payload)

        _ ->
          Logger.debug("Unhandled Event #{event}")
          :ok
      end

    json(conn, %{status: status})
  end

  defp repo_install_event(%{"action" => "added"} = payload) do
    Logger.info("Adding #{length(payload["repositories_added"])} Repos")

    Enum.each(payload["repositories_added"], fn repo ->
      GitHub.create_repository(%{name: repo["name"], github_id: repo["id"]})
    end)

    :created
  end

  defp repo_install_event(%{"action" => "removed"} = payload) do
    Logger.info("Deleting #{length(payload["repositories_removed"])} Repos")

    Enum.map(payload["repositories_removed"], fn repo -> repo["id"] end)
    |> GitHub.delete_repositories()

    :accepted
  end
end
