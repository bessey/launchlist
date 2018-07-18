defmodule Server.PullRequest do
  use Ecto.Schema
  import Ecto.Changeset


  schema "pull_requests" do
    field :pull_request_id, :integer
    has_many :working_lists, Server.WorkingList

    timestamps()
  end

  @doc false
  def changeset(pull_request, attrs) do
    pull_request
    |> cast(attrs, [:pull_request_id])
    |> validate_required([:pull_request_id])
  end
end
