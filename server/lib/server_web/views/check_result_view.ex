defmodule ServerWeb.CheckResultView do
  use ServerWeb, :view

  def check_form(conn, check_result_id, function) do
    form_for(
      conn,
      pull_request_check_result_path(
        conn,
        :update,
        conn.params["pull_request_id"],
        check_result_id
      ),
      [as: "check_params", method: "PUT", data: [target: "check.form"], class: "check-form"],
      function
    )
  end
end
