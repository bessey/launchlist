defmodule GitHubWebhookHeaders do
  @moduledoc """
  Plug to add GitHub webhook headers to the connection assigns, making pattern matching simpler
  """
  import Plug.Conn
  require Logger

  @event String.downcase("X-GitHub-Event")
  @delivery String.downcase("X-GitHub-Delivery")
  # @signature String.downcase("X-Hub-Signature")

  def init(opts), do: opts

  def call(conn, _opts) do
    event = get_req_header(conn, @event)
    delivery = get_req_header(conn, @delivery)
    # TODO: Check signature
    call_with_event(conn, event, delivery)
  end

  defp call_with_event(conn, [event], [delivery]) do
    Logger.info("GitHub Event Delivery ID: #{delivery}")
    assign(conn, :github_event, event)
  end

  defp call_with_event(conn, _, _) do
    conn
    |> send_resp(Plug.Conn.Status.code(:bad_request), "Couldn't find Event or Delivery")
    |> halt()
  end
end
