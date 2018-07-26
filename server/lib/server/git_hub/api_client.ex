defmodule Server.GitHub.ApiClient do
  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://api.github.com")
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Headers, [{"accept", "application/vnd.github.v3+json"}])

  plug(
    Tesla.Middleware.Query,
    client_id: Application.get_env(:server, :github_oauth_client_id),
    client_secret: Application.get_env(:server, :github_oauth_client_secret)
  )

  @spec post(String.t(), String.t(), map) :: Tesla.Env.result()
  def send_check_run(repo_owner, repo_name, %{external_id: id} = attrs) do
    body =
      Map.merge(attrs, %{
        name: "check-diff",
        details_url: details_url(id)
      })

    post("/repos/" <> repo_owner <> "/" <> repo_name <> "/check-runs", body)
  end

  defp details_url(id) do
    # TODO replace with a good URL
    Integer.to_string(id)
    # ServerWeb.Router.Helpers.working_list_url(ServerWeb.Endpoint, id)
  end
end
