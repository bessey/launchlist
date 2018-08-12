defmodule ServerWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """
  use ServerWeb, :controller

  plug(Ueberauth)

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    with {:ok, user} <- Server.Accounts.get_or_create_from_auth(auth),
         {:ok, _} <- Server.GitHub.update_repositories_for_user(user) do
      conn
      |> put_flash(
        :info,
        "Successfully authenticated, welcome #{user.github_username} / #{user.email}."
      )
      |> put_session(:current_user, user)
      |> redirect(to: "/")
    else
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
