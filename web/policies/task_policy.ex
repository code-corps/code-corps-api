defmodule CodeCorps.TaskPolicy do
  import CodeCorps.Helpers.Policy,
    only: [get_project: 1, administered_by?: 2, task_authored_by?: 2]

  alias CodeCorps.{Task, User}
  alias Ecto.Changeset

  def create?(%User{} = user, %Changeset{changes: %{user_id: author_id}}),
    do: user.id == author_id

  def update?(%User{} = user, %Task{} = task) do
    case task |> task_authored_by?(user) do
      true -> true
      false -> task |> get_project |> administered_by?(user)
    end
  end
end
