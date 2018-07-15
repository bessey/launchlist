defmodule Server.CheckList do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, except: [cast: 3]

  defenum(StatusEnum, new: 1, in_progress: 2, complete: 3)

  schema "check_lists" do
    field(:data, :map)
    field(:head_sha, :string)
    field(:status, StatusEnum)
    field(:pull_request_id, :id)

    timestamps()
  end

  @doc false
  def changeset(check_list, attrs) do
    check_list
    |> cast(attrs, [:head_sha, :status, :data])
    |> validate_required([:head_sha, :status, :data])
  end
end
