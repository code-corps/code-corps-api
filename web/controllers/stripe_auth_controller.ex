defmodule CodeCorps.StripeAuthController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Project
  alias CodeCorps.Repo
  alias CodeCorps.StripeAuth
  alias CodeCorps.User

  plug :load_and_authorize_resource, model: Project, only: [:stripe_auth]

  # We're using `stripe_auth` instead of `show` to use the Organization
  # policy for authorization
  def stripe_auth(conn, %{"id" => project_id}) do
    user = conn.assigns[:current_user]
    
    project =
      Project
      |> Repo.get(project_id)
      |> Repo.preload([:organization])

    case StripeAuth.authorize_url(user, project) do
      {:ok, url} ->
        stripe_auth = %StripeAuth{url: url}

        conn
        |> render(:show, data: stripe_auth)
      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", message: reason)
    end
  end
end
