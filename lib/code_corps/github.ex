defmodule CodeCorps.Github do

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
end
