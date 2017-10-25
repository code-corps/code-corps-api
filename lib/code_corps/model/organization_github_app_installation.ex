defmodule CodeCorps.OrganizationGithubAppInstallation do
  use CodeCorps.Model

  schema "organization_github_app_installations" do
    belongs_to :github_app_installation, CodeCorps.GithubAppInstallation
    belongs_to :organization, CodeCorps.Organization

    timestamps(type: :utc_datetime)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, [:github_app_installation_id, :organization_id])
    |> validate_required([:github_app_installation_id, :organization_id])
    |> assoc_constraint(:github_app_installation, name: "organization_github_app_installations_github_app_installation_i")
    |> assoc_constraint(:organization)
  end
end
