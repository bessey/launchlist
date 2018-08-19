defmodule ServerWeb.LayoutView do
  use ServerWeb, :view
  import ServerWeb.Helpers.Auth

  def current_user(conn) do
    get_current_user(conn)
  end
end
