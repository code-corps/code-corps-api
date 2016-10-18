defmodule CodeCorps.StripeAuthController do
  use CodeCorps.Web, :controller

  alias CodeCorps.Project
  alias CodeCorps.StripeAuth

  plug :load_and_authorize_resource, model: Project, only: [:stripe_auth]

  # We're using `stripe_auth` instead of `show` to use the Project
  # policy for authorization
  def stripe_auth(conn, %{"id" => project_id}) do
    project = Repo.get(Project, project_id)
    case StripeAuth.generate_button_url(project) do
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
