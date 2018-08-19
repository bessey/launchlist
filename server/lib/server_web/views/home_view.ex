defmodule ServerWeb.HomeView do
  use ServerWeb, :view

  def render("pitch.html", %{conn: conn}) do
    render_template("pitch.html", %{conn: conn})
  end
end
