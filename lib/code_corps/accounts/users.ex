defmodule CodeCorps.Accounts.Users do
  alias CodeCorps.ProjectUser

  import Ecto.Query

  def project_filter(query, %{"project_id" => project_id}) do
    from user in query,
      join: pu in ProjectUser, on: pu.user_id == user.id and pu.project_id == ^project_id
  end
  def project_filter(query, _), do: query
end