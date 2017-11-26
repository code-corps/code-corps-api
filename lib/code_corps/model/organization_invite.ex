defmodule CodeCorps.OrganizationInvite do
  @moduledoc """
  Handles inviting organizations via email
  """

  use CodeCorps.Model

  @type t :: %__MODULE__{}

  schema "organization_invites" do
    field :code, :string
    field :email, :string
    field :fulfilled, :boolean, default: false
    field :organization_name, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :organization_name, :fulfilled])
    |> validate_required([:email, :organization_name])
    |> validate_format(:email, ~r/@/)
    |> validate_change(:fulfilled, &check_fulfilled_changes_to_true/2)
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

  defp check_fulfilled_changes_to_true :fulfilled, fulfilled do
    if fulfilled == false do
      [fulfillled: "Fulfilled can only change from false to true"]
    else
      []
    end
  end
end
