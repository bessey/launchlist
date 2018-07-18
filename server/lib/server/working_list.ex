defmodule Server.WorkingList do
  @doc """
    Represents an in-progress checklist, generated for a particular revision of a pull request
  """
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, except: [cast: 3]

  defenum(StatusEnum, new: 1, in_progress: 2, complete: 3)

  schema "working_lists" do
    field(:category, :string)
    field(:version, :integer)
    field(:data, :map)
    field(:head_sha, :string)
    field(:status, StatusEnum)
    field(:pull_request_id, :id)

    timestamps()
  end

  @doc false
  def changeset(working_list, attrs) do
    working_list
    |> cast(attrs, [:head_sha, :status, :data])
    |> validate_required([:head_sha, :status, :data])
  end
end
