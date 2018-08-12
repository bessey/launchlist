defmodule ServerWeb.Api.GitHub.WebhookController do
  use ServerWeb, :controller
  require Logger
  alias Server.{GitHub, Checker}

  plug(GitHubWebhookHeaders)

  def create(%{assigns: %{github_event: event}} = conn, payload) do
    Logger.debug("Processing Event: '#{event}'")
    response = process_event(event, payload)

    conn
    |> put_status(response.status)
    |> json(response)
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
      GitHub.upsert_repo_from_github(repo["id"], %{name: repo["full_name"]})
    end)

    %{status: :created}
  end

  defp process_event("installation_repositories", %{"action" => "removed"} = payload) do
    Logger.info("Deleting #{length(payload["repositories_removed"])} Repos")

    Enum.map(payload["repositories_removed"], fn repo -> repo["id"] end)
    |> GitHub.delete_repositories_from_github()

    %{status: :accepted}
  end

  defp process_event("pull_request", %{"action" => "opened"} = payload),
    do: pull_request_update(payload)

  defp process_event("pull_request", %{"action" => "synchronize"} = payload),
    do: pull_request_update(payload)

  defp process_event(event, _) do
    Logger.debug("Unhandled Event #{event}")
    %{status: :ok}
  end

  defp check_suite_requested(%{} = payload) do
    Enum.each(payload["check_suite"]["pull_requests"], fn pr ->
      with {:ok, repo} <-
             GitHub.upsert_repo_from_github(payload["repository"]["id"], %{
               name: payload["repository"]["full_name"]
             }),
           {:ok, pull_request} <-
             GitHub.upsert_pull_request_from_github(pr["id"], %{
               head_branch: pr["head"]["ref"],
               base_branch: pr["base"]["ref"],
               repository_id: repo.id
             }),
           {:ok, check_run} <-
             GitHub.upsert_check_run_from_github(
               pull_request,
               %{
                 head_sha: Map.fetch!(payload["check_suite"], "head_sha")
               }
             ),
           {:ok, check_result_set} <-
             check_run
             |> Ecto.build_assoc(:check_result_set)
             |> Map.from_struct()
             |> Checker.create_check_result_set() do
        GitHub.send_queued_check_run(pull_request, check_run, check_result_set)
      else
        error -> raise inspect(error)
      end
    end)

    # TODO handle errors
    %{status: :accepted}
  end

  defp pull_request_update(payload) do
    repo_github_id = Map.fetch!(payload["repository"], "id")
    pr_github_id = Map.fetch!(payload["pull_request"], "id")

    with repo_attrs <- %{name: payload["repository"]["full_name"]},
         {:ok, repo} <- GitHub.upsert_repo_from_github(repo_github_id, repo_attrs),
         pr_attrs <- %{
           repository_id: repo.id,
           base_branch: payload["pull_request"]["base"]["ref"],
           head_branch: payload["pull_request"]["head"]["ref"]
         },
         {:ok, _} <- GitHub.upsert_pull_request_from_github(pr_github_id, pr_attrs) do
      %{status: :created}
    else
      error -> %{status: :bad_request, error: inspect(error)}
    end
  end
end
