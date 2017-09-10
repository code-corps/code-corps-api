defmodule CodeCorpsWeb.GuardianSerializer do
  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.User

  @behaviour Guardian.Serializer

  def for_token(project = %Project{}), do: {:ok, "Project:#{project.id}"}
  def for_token(user = %User{}), do: {:ok, "User:#{user.id}"}
  def for_token(_), do: {:error, "Unknown resource type"}

  def from_token("Project:" <> id), do: {:ok, Repo.get(Project, id)}
  def from_token("User:" <> id) do
    user = Repo.get(User, id)

    if user do
      name = full_name(user)
      %Timber.Contexts.UserContext{id: user.id, email: user.email, name: name}
      |> Timber.add_context()
    end

    {:ok, user}
  end
  def from_token(_), do: {:error, "Unknown resource type"}

  defp full_name(%User{first_name: nil, last_name: nil}), do: ""
  defp full_name(%User{first_name: first_name, last_name: nil}), do: first_name
  defp full_name(%User{first_name: nil, last_name: last_name}), do: last_name
  defp full_name(%User{first_name: first_name, last_name: last_name}) do
    first_name <> " " <> last_name
  end
  defp full_name(_), do: ""
end
