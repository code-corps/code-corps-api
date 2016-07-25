defmodule CodeCorps.TestHelpers do
  alias CodeCorps.Repo

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      email: "username",
      username: "user#{Base.encode16(:crypto.rand_bytes(8))}",
      password: "password",
    }, attrs)

    %CodeCorps.User{}
    |> CodeCorps.User.registration_changeset(changes)
    |> Repo.insert!()
  end
end
