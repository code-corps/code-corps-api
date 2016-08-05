defmodule CodeCorps.User do
  use CodeCorps.Web, :model

  schema "users" do
    field :biography, :string
    field :encrypted_password, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true
    field :twitter, :string
    field :username, :string
    field :website, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :username])
    |> validate_required([:email, :username])
    |> validate_length(:username, min: 1, max: 39)
  end

  @doc """
  Builds a changeset for registering the user.
  """
  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_required(:password)
    |> validate_length(:password, min: 6)
    |> put_pass_hash()
  end

  def update_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:first_name, :last_name, :twitter, :biography, :website])
    |> prefix_url(:website)
    |> validate_format(:website, ~r/\A((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}(([0-9]{1,5})?\/.*)?#=\z/ix)
    |> validate_format(:twitter, ~r/\A[a-zA-Z0-9_]{1,15}\z/)
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp prefix_url(changeset, key) do
    changeset
    |> update_change(key, &do_prefix_url/1)
  end
  defp do_prefix_url(nil), do: nil
  defp do_prefix_url("http://" <> rest), do: "http://" <> rest
  defp do_prefix_url("https://" <> rest), do: "https://" <> rest
  defp do_prefix_url(value), do: "http://" <> value
end
