defmodule ServerWeb.Api.CheckListController do
  use ServerWeb, :controller

  def post(conn, _params) do
    render conn, "index.html"
  end
end
