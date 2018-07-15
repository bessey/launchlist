defmodule ServerWeb.Api.CheckListController do
  use ServerWeb, :controller
  alias Server.{Repo, CheckList}
  require Logger

  def create(conn, %{"data" => data}) do
    config = Server.CheckResult.from_map(data)

    # TODO actually get this myself
    fake_data = %CheckList{head_sha: "abcdef", status: :new}

    Repo.insert(%CheckList{fake_data | data: Map.from_struct(config)})

    json(conn, %{status: :ok})
  end
end
