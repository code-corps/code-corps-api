defmodule CodeCorps.Web.ProjectSkillPolicy do
  import CodeCorps.Helpers.Policy, only: [get_project: 1, administered_by?: 2]

  alias CodeCorps.Web.{ProjectSkill, User}
  alias Ecto.Changeset

  def create?(%User{} = user, %Changeset{} = changeset) do
    changeset |> get_project |> administered_by?(user)
  end

  def delete?(%User{} = user, %ProjectSkill{} = project_skill) do
    project_skill |> get_project |> administered_by?(user)
  end
end
