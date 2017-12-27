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
  defp resource_from_subject("User:" <> id), do: {:ok, Repo.get(User, id)}
  defp resource_from_subject(_), do: {:error, :unknown_resource_type}
end
