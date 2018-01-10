defmodule CodeCorpsWeb.UserInviteController do
  @moduledoc false
  use CodeCorpsWeb, :controller

  alias CodeCorps.{Accounts, Analytics.SegmentTracker, User, UserInvite}

  action_fallback CodeCorpsWeb.FallbackController
  plug CodeCorpsWeb.Plug.DataToAttributes
  plug CodeCorpsWeb.Plug.IdsToIntegers

  @spec create(Plug.Conn.t, map) :: Conn.t
  def create(%Conn{} = conn, %{} = params) do
    with %User{} = current_user <- conn |> CodeCorps.Guardian.Plug.current_resource,
         {:ok, :authorized} <- current_user |> Policy.authorize(:create, %UserInvite{}, params),
         {:ok, %UserInvite{} = user_invite} <- params |> Accounts.create_invite() do

      current_user.id |> SegmentTracker.track("Created User Invite", user_invite)
      conn |> put_status(:created) |> render("show.json-api", data: user_invite)
    end
  end
end
