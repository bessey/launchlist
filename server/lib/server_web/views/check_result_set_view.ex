defmodule ServerWeb.CheckResultSetView do
  use ServerWeb, :view

  def check_form(conn, function) do
    form_for(
      conn,
      pull_request_check_result_set_path(
        conn,
        :update,
        conn.params["pull_request_id"],
        conn.params["id"]
      ),
      [as: "check_params", method: "PUT", data: [target: "check.form"], class: "check-form"],
      function
    )
  end
end
