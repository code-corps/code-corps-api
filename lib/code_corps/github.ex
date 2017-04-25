defmodule CodeCorps.Github do

  alias CodeCorps.{User, Repo}

  def associate(user, params) do
    user
    |> User.github_associate_changeset(params)
    |> Repo.update()
  end
end