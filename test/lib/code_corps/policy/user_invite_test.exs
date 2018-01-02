defmodule CodeCorps.Policy.UserInviteTest do
  use CodeCorps.PolicyCase

  alias CodeCorps.{Policy.UserInvite, Repo}
  alias Ecto.Changeset

  describe "create?" do
    defp set_role(membership, role) do
      membership |> Changeset.change(%{role: role}) |> Repo.update()
    end

    test "returns true if no project/role specified" do
      user = insert(:user)
      assert user |> UserInvite.create?(%{}) == true
    end

    test "when invite for project contributor, returns true if user is admin or higher" do
      project = insert(:project)
      user = insert(:user)
      attrs = %{"project_id" => project.id, "role" => "contributor"}

      refute user |> UserInvite.create?(attrs)
      membership = insert(:project_user, project: project, user: user, role: "pending")
      refute user |> UserInvite.create?(attrs)
      membership |> set_role("contributor")
      refute user |> UserInvite.create?(attrs)
      membership |> set_role("admin")
      assert user |> UserInvite.create?(attrs)
      membership |> set_role("owner")
      assert user |> UserInvite.create?(attrs)
    end

    test "when invite for project admin, returns true if user is owner" do
      project = insert(:project)
      user = insert(:user)
      attrs = %{"project_id" => project.id, "role" => "admin"}

      refute user |> UserInvite.create?(attrs)
      membership = insert(:project_user, project: project, user: user, role: "pending")
      refute user |> UserInvite.create?(attrs)
      membership |> set_role("contributor")
      refute user |> UserInvite.create?(attrs)
      membership |> set_role("admin")
      refute user |> UserInvite.create?(attrs)
      membership |> set_role("owner")
      assert user |> UserInvite.create?(attrs)
    end
  end
end
