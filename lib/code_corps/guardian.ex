defmodule CodeCorps.Guardian do
  use Guardian, otp_app: :code_corps

  alias CodeCorps.{Project, Repo, User}

  def subject_for_token(project = %Project{}, _claims) do
    {:ok, "Project:#{project.id}"}
  end
  def subject_for_token(user = %User{}, _claims) do
    {:ok, "User:#{user.id}"}
  end
  def subject_for_token(_, _) do
    {:error, :unknown_resource_type}
  end

  def resource_from_claims(%{"sub" => sub}), do: resource_from_subject(sub)
  def resource_from_claims(_), do: {:error, :missing_subject}

  defp resource_from_subject("Project:" <> id), do: {:ok, Repo.get(Project, id)}
  defp resource_from_subject("User:" <> id) do
    user = Repo.get(User, id)

    if user do
      name = full_name(user)
      %Timber.Contexts.UserContext{id: user.id, email: user.email, name: name}
      |> Timber.add_context()
    end

    {:ok, user}
  end
  defp resource_from_subject(_), do: {:error, :unknown_resource_type}

  defp full_name(%User{first_name: nil, last_name: nil}), do: ""
  defp full_name(%User{first_name: first_name, last_name: nil}), do: first_name
  defp full_name(%User{first_name: nil, last_name: last_name}), do: last_name
  defp full_name(%User{first_name: first_name, last_name: last_name}) do
    first_name <> " " <> last_name
  end
  defp full_name(_), do: ""
end
