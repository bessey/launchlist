defmodule Server.CheckList do
  use Ecto.Schema
  import Ecto.Changeset


  schema "check_lists" do
    field :data, :map
    field :head_sha, :string
    field :status, :integer
    field :pull_request_id, :id

    timestamps()
  end

  @doc false
  def changeset(check_list, attrs) do
    check_list
    |> cast(attrs, [:head_sha, :status, :data])
    |> validate_required([:head_sha, :status, :data])
  end
end
