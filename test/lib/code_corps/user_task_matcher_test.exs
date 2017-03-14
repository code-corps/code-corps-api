defmodule CodeCorps.UserTaskMatcherTest do
  use CodeCorps.ModelCase

  import CodeCorps.UserTaskMatcher

  test "can find top x tasks for a user's skill" do
    coding = insert(:skill, title: "coding")
    design = insert(:skill, title: "design")

    account_page = insert(:task)
    settings_page = insert(:task)
    photoshop = insert(:task)

    insert(:task)

    insert(:task_skill, task: account_page, skill: design)
    insert(:task_skill, task: account_page, skill: coding)
    insert(:task_skill, task: settings_page, skill: design)
    insert(:task_skill, task: settings_page, skill: coding)
    insert(:task_skill, task: photoshop, skill: coding)

    user = insert(:user)

    insert(:user_skill, user: user, skill: design)
    insert(:user_skill, user: user, skill: coding)

    tasks = match_user(user, 2)

    assert(length(tasks) == 2)
    assert(length(match_user(user, 3)) == 3)
  end
end
