defmodule CodeCorps.Emails.Recipient do
  @moduledoc ~S"""
  In charge of adapting `CodeCorps.User` data into SparkPost recipient data.
  """

  alias CodeCorps.{OrganizationInvite, User}

  @doc ~S"""
  From the provided record, builds a valid SparkPost recipient

  See https://developers.sparkpost.com/api/recipient-lists.html#header-address-attributes

  Though SparkPost specifies the address could also be a string type, containing
  just the email, it's simpler to always treat it as a map, so that is what we
  do.
  """
  @spec build(OrganizationInvite.t | User.t) :: map
  def build(%User{} = user) do
    %{address: user |> build_address()}
  end
  def build(%OrganizationInvite{} = invite) do
    %{address: invite |> build_address()}
  end

  @spec build_address(OrganizationInvite.t | User.t) :: map
  defp build_address(%User{first_name: nil, email: email}), do: %{email: email}
  defp build_address(%User{first_name: name, email: email}) do
    %{email: email, name: name}
  end
  defp build_address(%OrganizationInvite{organization_name: nil, email: email}) do
    %{email: email}
  end
  defp build_address(%OrganizationInvite{organization_name: name, email: email}) do
    %{email: email, name: name}
  end
end
