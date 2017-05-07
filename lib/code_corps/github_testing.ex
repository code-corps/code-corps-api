defmodule CodeCorps.GithubTesting do
  def create_issue(attributes, _project, _current_user) do
    case attributes["error_testing"] do
      true ->
        nil
      _ ->
        1 # Return github id
    end
  end
end
