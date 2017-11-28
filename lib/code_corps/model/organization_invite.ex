defmodule CodeCorps.OrganizationInvite do
  @moduledoc """
  Handles inviting organizations via email
  """

  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "organization_invites" do
    field :code, :string
    field :email, :string
    field :organization_name, :string

    belongs_to :organization, CodeCorps.Organization

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :organization_name])
    |> validate_required([:email, :organization_name])
    |> validate_format(:email, ~r/@/)
  end

  @doc """
  Builds a changeset for creating an organization invite.
  """
  def create_changeset(struct, params) do
    struct
    |> changeset(params)
    |> generate_code
    |> unique_constraint(:code)
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:organization_id])
    |> assoc_constraint(:organization)
  end

  defp generate_code(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true}  ->
        code = do_generate_code(10)
        put_change(changeset, :code, code)
      _ -> changeset
     end
  end

  defp do_generate_code(length) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.encode64
    |> binary_part(0, length)
  end
end
