defmodule CodeCorpsWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use CodeCorpsWeb, :controller
      use CodeCorpsWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      use Timex.Ecto.Timestamps
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, log: false, namespace: CodeCorpsWeb
      use ScoutApm.Instrumentation

      import Ecto
      import Ecto.Query

      import CodeCorpsWeb.Router.Helpers
      import CodeCorpsWeb.Gettext

      alias CodeCorps.{Repo, Policy}
      alias Plug.Conn
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/code_corps_web/templates",
                        namespace: CodeCorpsWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import CodeCorpsWeb.Router.Helpers
      import CodeCorpsWeb.ErrorHelpers
      import CodeCorpsWeb.Gettext
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel, log_join: false, log_handle_in: false

      alias CodeCorps.Repo
      import Ecto
      import Ecto.Query
      import CodeCorpsWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
