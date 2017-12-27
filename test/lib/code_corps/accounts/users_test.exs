defmodule CodeCorps.Accounts.UsersTest do
  @moduledoc false

  use CodeCorps.DbAccessCase
  import CodeCorps.TestHelpers, only: [assert_ids_from_query: 2]

  alias CodeCorps.{Accounts, User}

  describe "project_filter/2" do
    test "filters users by project filter" do
      user_1 = insert(:user)
      user_2 = insert(:user)

      project = insert(:project)

      insert(:project_user, user: user_1, project: project)
      insert(:project_user, user: user_2, project: project)
      insert(:project_user)

      result =
        User
        |> Accounts.Users.project_filter(%{"project_id" => project.id})
        |> Repo.all()

      assert_ids_from_query(result, [user_1.id, user_2.id])
     end
  end
end