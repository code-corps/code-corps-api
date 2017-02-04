defmodule CodeCorps.Analytics.SegmentDataExtractor do
  @moduledoc """
  Extract data for use in Segment tracking
  """

  @spec get_action(Plug.Conn.t) :: atom
  def get_action(%Plug.Conn{private: %{phoenix_action: action}}), do: action

  @spec get_resource(Plug.Conn.t) :: struct
  def get_resource(%Plug.Conn{assigns: %{data: data}}), do: data
  # these are used for delete actions on records that support it
  # we render a 404 in those cases, so data is never assigned
  def get_resource(%Plug.Conn{assigns: %{user_category: data}}), do: data
  def get_resource(%Plug.Conn{assigns: %{user_role: data}}), do: data
  def get_resource(%Plug.Conn{assigns: %{user_skill: data}}), do: data
  def get_resource(%Plug.Conn{assigns: %{token: token, user_id: user_id}}) do
    %{token: token, user_id: user_id}
  end
  def get_resource(_), do: nil

  @spec get_user_id(Plug.Conn.t, CodeCorps.User.t | struct | map) :: String.t
  def get_user_id(%Plug.Conn{assigns: %{current_user: %CodeCorps.User{id: id}}}, _), do: id
  def get_user_id(_, %CodeCorps.User{id: id}), do: id
  def get_user_id(_, %{user_id: user_id}), do: user_id
end
