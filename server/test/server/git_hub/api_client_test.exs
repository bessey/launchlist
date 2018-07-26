defmodule Server.GitHub.ApiTest do
  use ExUnit.Case
  alias Server.GitHub.{ApiClient}
  doctest ApiClient

  import Tesla.Mock

  describe "send_pending_check_run" do
    setup do
      mock(fn
        %{
          method: :post,
          url: "https://api.github.com/repos/bessey/checklint/check-runs",
          headers: [
            {"content-type", "application/json"},
            {"accept", "application/vnd.github.v3+json"}
          ],
          query: [client_id: "1234", client_secret: "abcd"]
        } ->
          json(%{"id" => 4})

        params ->
          raise ArgumentError, "Mock called with unexpected params" <> inspect(params)
      end)

      :ok
    end

    test "it hits the GitHub Checks API endpoint" do
      data = %{
        external_id: 123,
        status: "in_progress",
        details_url: "123"
      }

      assert ApiClient.send_pending_check_run("bessey", "checklint", data) ==
               {:ok,
                %Tesla.Env{
                  body: %{"id" => 4},
                  headers: [{"content-type", "application/json"}],
                  status: 200
                }}
    end
  end
end
