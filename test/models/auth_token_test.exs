defmodule CodeCorps.AuthTokenTest do
  use CodeCorps.ModelCase

  alias CodeCorps.AuthToken

  test "changeset with valid attributes" do
    user = insert(:user)
    changeset = AuthToken.changeset(%AuthToken{}, user)
    assert changeset.valid?
    assert changeset.changes.value
  end

end
