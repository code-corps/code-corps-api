defmodule CodeCorps.Policy.Task do
  @moduledoc ~S"""
  Authorization policy in charge of dermining if a `User` is authorized to
  perform an action on a `Task`.
  """
  import CodeCorps.Policy.Helpers,
    only: [get_project: 1, administered_by?: 2, task_authored_by?: 2]

  alias CodeCorps.{Task, User}

  def create?(%User{id: user_id}, %{"user_id" => author_id})
    when user_id == author_id and not is_nil(user_id), do: true
  def create?(%User{}, %{}), do: false

  def update?(%User{} = user, %Task{} = task) do
    case task |> task_authored_by?(user) do
      true -> true
      false -> task |> get_project |> administered_by?(user)
    end
  end
end
