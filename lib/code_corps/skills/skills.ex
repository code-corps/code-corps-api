defmodule CodeCorps.Skills do
  @moduledoc ~S"""
  Work with skills.
  """

  alias CodeCorps.{
    Repo,
    Skill,
    UserSkill
  }

  import Ecto.Query

  @doc """
  Find the most popular skills, in order, with a limit.
  """
  @spec popular(map) :: [Skill.t]
  def popular(params \\ %{})
  def popular(%{"limit" => limit}), do: limit |> Integer.parse() |> apply_limit()
  def popular(_), do: do_popular()

  defp apply_limit({limit, _rem}) when limit <= 100, do: do_popular(limit)
  defp apply_limit(_), do: do_popular()

  @spec do_popular(pos_integer) :: [Skill.t]
  def do_popular(limit \\ 10) do
    query =
      from s in Skill,
        join: us in UserSkill,
          on: s.id == us.skill_id,
          group_by: s.id,
          order_by: [desc: count(us.skill_id)],
          limit: ^limit

    query
    |> Repo.all()
  end
end
