defmodule CodeCorps.Transition.GithubAppInstallationState do
  @moduledoc """
  Governs the transitioning from one state to the next.

  The possible `state` values are:

  - `initiated_on_code_corps` - The user clicks a button or link in the Code Corps UI and is redirected to GitHub to install. This process creates the `GithubAppInstallation` record before redirecting.
  - `initiated_on_github` - We receive an installation webhook with a matching user, but an installation was never created on Code Corps. This can happen because GitHub does not assume an app will _only_ be installed at a starting point outside GitHub.
  - `processing` - When the installation webhook is received, was matched, and is now processing.
  - `processed` - The integration process is completed. There is now a working installation attached to the project.
  - `unmatched_user` - When we receive a webhook but there is no Code Corps user matching the given GitHub user's GitHub `id`. This is sent in the `sender` key of the `installation` event by GitHub.

  It is possible to resolve more problematic states like `unmatched_user` when the user provides more information, e.g. connecting their GitHub account. The transitions below allow for some of these edge cases.
  """

  def next(nil, "initiated_on_code_corps"), do: {:ok, "initiated_on_code_corps"}

  def next(current_state, nil), do: {:ok, current_state}

  def next("initiated_on_code_corps", "processing"), do: {:ok, "processing"}
  def next("initiated_on_code_corps", "processed"), do: {:ok, "processed"}
  def next("initiated_on_code_corps", "unmatched_user"), do: {:ok, "unmatched_user"}

  def next("processing", "processed"), do: {:ok, "processed"}
  def next("processing", "unmatched_user"), do: {:ok, "unmatched_user"}

  def next("unmatched_user", "processing"), do: {:ok, "processing"}
  def next("unmatched_user", "processed"), do: {:ok, "processed"}

  def next(current_state, next_state) when current_state == next_state, do: {:ok, next_state}
  def next(current_state, next_state), do: {:error, "invalid transition to #{next_state} from #{current_state}"}
end
