defmodule ServerWeb.PullRequestView do
  use ServerWeb, :view
  def latest_sha(nil), do: nil
  def latest_sha(check_run), do: check_run.head_sha
end
