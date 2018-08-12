defmodule ServerWeb.Helpers.Auth do
  @current_user_id :current_user_id

  import Plug.Conn
  require Logger

  @spec signed_in?(Plug.Conn.t()) :: boolean()
  def signed_in?(conn) do
    !!get_current_user(conn)
  end

  @spec get_current_user(Plug.Conn.t()) :: nil | Server.Accounts.User
  def get_current_user(conn) do
    user_id = get_current_user_id(conn)
    if user_id, do: Server.Repo.get(Server.Accounts.User, user_id)
  end

  @spec get_current_user_id(Plug.Conn.t()) :: nil | Integer
  def get_current_user_id(conn) do
    Plug.Conn.get_session(conn, @current_user_id)
  end

  @spec sign_in_user(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def sign_in_user(conn, user_id) do
    Logger.debug("Signined in #{user_id}")
    conn |> put_session(@current_user_id, user_id)
  end
end
