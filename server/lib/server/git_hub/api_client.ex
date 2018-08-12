defmodule Server.GitHub.ApiClient do
  use Tesla
  require Logger

  plug(Tesla.Middleware.BaseUrl, "https://api.github.com")
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Headers, [{"accept", "application/vnd.github.v3+json"}])

  plug(
    Tesla.Middleware.Query,
    client_id: Application.get_env(:server, :github_oauth_client_id),
    client_secret: Application.get_env(:server, :github_oauth_client_secret)
  )

  @spec send_check_run(String.t(), %{external_id: any()}) ::
          {:error, any()} | {:ok, Tesla.Env.t()}
  def send_check_run(repo_name, %{external_id: id} = attrs) do
    Logger.info("GitHub API: POST check-runs #{repo_name}")

    body =
      Map.merge(attrs, %{
        name: "check-diff",
        details_url: details_url(id)
      })

    post("/repos/#{repo_name}/check-runs", body)
  end

  @spec rest_client(String.t()) :: Tentacat.Client.t()
  def rest_client(access_token) do
    Tentacat.Client.new(%{access_token: access_token})
  end

  defp details_url(id) do
    # TODO replace with a good URL
    Integer.to_string(id)
    # ServerWeb.Router.Helpers.working_list_url(ServerWeb.Endpoint, id)
  end
end
