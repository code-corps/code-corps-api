defmodule CodeCorpsWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "conversation:*", CodeCorpsWeb.ConversationChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket,
    timeout: 45_000,
    check_origin: Application.get_env(:code_corps, :allowed_origins)
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket) do
    with {:ok, claims} <- CodeCorps.Guardian.decode_and_verify(token),
         {:ok, user} <- CodeCorps.Guardian.resource_from_claims(claims) do
      {:ok, assign(socket, :current_user, user)}
    else
      _ -> {:ok, socket}
    end
  end
  def connect(_params, socket) do
    {:ok, socket}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     CodeCorpsWeb.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
