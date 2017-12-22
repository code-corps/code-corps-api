defmodule CodeCorpsWeb.OrganizationInviteController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Emails, Helpers.Query, OrganizationInvite, User}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec index(Conn.t, map) :: Conn.t
  def index(%Conn{} = conn, %{} = params) do
    with organization_invites <- OrganizationInvite |> Query.id_filter(params) |> Query.optional_filters(params, ~w(code)a) |> Repo.all do
      conn |> render("index.json-api", data: organization_invites)
    end
  end

  @spec show(Conn.t, map) :: Conn.t
  def show(%Conn{} = conn, %{"id" => id}) do
    with %OrganizationInvite{} = organization_invite <- OrganizationInvite |> Repo.get(id) do
      conn |> render("show.json-api", data: organization_invite)
    end
  end

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %OrganizationInvite{}, params),
         {:ok, %OrganizationInvite{} = organization_invite} <- %OrganizationInvite{} |> OrganizationInvite.create_changeset(params) |> Repo.insert do

      organization_invite |> Emails.send_organization_invite_email

      conn
      |> put_status(:created)
      |> render("show.json-api", data: organization_invite)
    end
  end

  @spec update(Conn.t, map) :: Conn.t
  def update(%Conn{} = conn, %{"id" => id} = params) do
    with %OrganizationInvite{} = organization_invite <- OrganizationInvite |> Repo.get(id),
         %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:update, organization_invite),
         {:ok, %OrganizationInvite{} = organization_invite} <- organization_invite |> OrganizationInvite.changeset(params) |> Repo.update do
      conn |> render("show.json-api", data: organization_invite)
    end
  end
end
