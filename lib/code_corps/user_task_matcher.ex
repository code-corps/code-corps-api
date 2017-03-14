defmodule CodeCorps.UserTaskMatcher do
  @moduledoc """
  Find the top tasks most matching a User's skills
  """

  alias CodeCorps.{Repo, Task, User, TaskSkill}
  import Ecto.Query

  @spec match_user(User.t, number) :: [Task.t]
  def match_user(%CodeCorps.User{} = user, tasks_count) do
    query = from t in TaskSkill,
      join: skill in assoc(t, :skill),
      join: user_skill in assoc(skill, :user_skills),
      join: user in assoc(user_skill, :user),
      where: user.id == ^user.id,
      group_by: t.task_id,
      order_by: count(t.task_id),
      limit: ^tasks_count,
      select: t.task_id

    matches = query |> Repo.all

    Task |> where([t], t.id in ^matches) |> Repo.all
  end
end
