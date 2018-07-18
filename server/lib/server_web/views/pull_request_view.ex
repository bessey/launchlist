defmodule ServerWeb.PullRequestView do
  use ServerWeb, :view
  def latest_sha(nil),  do: nil
  def latest_sha(working_list), do: working_list.sha
end
