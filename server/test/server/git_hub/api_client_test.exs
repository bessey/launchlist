defmodule Server.GitHub.ApiTest do
  use ExUnit.Case
  alias Server.GitHub.{ApiClient}
  doctest ApiClient

  import Tesla.Mock

  describe "send_check_run/3" do
    test "hits the GitHub Checks API endpoint with the passed data" do
      data = %{
        external_id: 123,
        status: "in_progress",
        details_url: "123"
      }

      mock(fn
        %{
          method: :post,
          url: "https://api.github.com/repos/bessey/checklint/check-runs",
          headers: [
            {"content-type", "application/json"},
            {"accept", "application/vnd.github.v3+json"}
          ],
          # Auth headers
          query: [client_id: "1234", client_secret: "abcd"],
          body:
            "{\"details_url\":\"123\",\"external_id\":123,\"name\":\"check-diff\",\"status\":\"in_progress\"}"
        } ->
          json(%{"id" => 4})
      end)

      assert ApiClient.send_check_run("bessey", "checklint", data) ==
               {:ok,
                %Tesla.Env{
                  body: %{"id" => 4},
                  headers: [{"content-type", "application/json"}],
                  status: 200
                }}
    end
  end
end
