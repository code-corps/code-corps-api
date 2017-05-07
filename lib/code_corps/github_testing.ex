defmodule CodeCorps.GithubTesting do

  alias CodeCorps.{User, Repo}

  @doc """
  Temporary function until the actual behavior is implemented.
  """
  def connect(user, _code), do: {:ok, user}

  def associate(user, params) do
    user
    |> User.github_associate_changeset(params)
    |> Repo.update()
  end

  def create_issue(attributes, _project, _current_user) do
    case attributes["error_testing"] do
      true ->
        nil
      _ ->
        1 # Return github id
    end
  end
end
