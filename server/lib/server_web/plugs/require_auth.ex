defmodule ServerWeb.RequireAuth do
  @moduledoc """
  Plug to enforce authentication
  """
  import Plug.Conn
  require Logger
  import ServerWeb.Helpers.Auth

  def init(opts), do: opts

  def call(conn, _opts) do
    case signed_in?(conn) do
      true ->
        conn

      false ->
        conn
        |> Phoenix.Controller.render(ServerWeb.ErrorView, :"404")
        |> halt()
    end
  end
end
