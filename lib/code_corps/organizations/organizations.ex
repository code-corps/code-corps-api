defmodule CodeCorps.Organizations do
  @moduledoc ~S"""
  """

  alias CodeCorps.{Organization, OrganizationInvite, Repo}
  alias Ecto.{Changeset, Multi}

  @doc ~S"""
  Creates a `CodeCorps.Organization` from a set of parameters,
  fulfilling the associated `CodeCorps.OrganizationInvite`, if it exists, by
  associating it with the created record.
  """
  @spec create(map) :: {:ok, Organization.t} | {:error, Changeset.t}
  def create(%{} = params) do
    Multi.new()
    |> Multi.insert(:organization, Organization.create_changeset(%Organization{}, params))
    |> Multi.run(:organization_invite, fn %{organization: organization} -> organization |> fulfill_associated_invite(params) end)
    |> Repo.transaction()
    |> handle_result()
  end

  @spec fulfill_associated_invite(Organization.t, map) :: {:ok, OrganizationInvite.t | nil} | {:error, Changeset.t}
  defp fulfill_associated_invite(%Organization{id: organization_id}, %{"invite_code" => code}) do
    OrganizationInvite
    |> Repo.get_by(code: code)
    |> OrganizationInvite.update_changeset(%{organization_id: organization_id})
    |> Repo.update()
  end
  defp fulfill_associated_invite(%Organization{}, %{}), do: {:ok, nil}

  @spec handle_result(tuple) :: tuple
  defp handle_result({:ok, %{organization: %Organization{} = organization}}) do
    {:ok, organization}
  end
  defp handle_result({:error, :organization, %Changeset{} = changeset, _steps}) do
    {:error, changeset}
  end
  defp handle_result({:error, :organization_invite, %Changeset{} = changeset, _steps}) do
    {:error, changeset}
  end
end
