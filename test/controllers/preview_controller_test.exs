defmodule CodeCorps.PreviewControllerTest do
  use CodeCorps.ConnCase

  alias CodeCorps.Preview

  setup do
    conn =
      %{build_conn | host: "api."}
      |> put_req_header("accept", "application/vnd.api+json")
      |> put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end

  test "creates and renders resource, with body containing markdown rendered to html", %{conn: conn} do
    conn = post conn, preview_path(conn, :create), %{
      "meta" => %{},
      "data" => %{"type" => "preview","attributes" => %{markdown: "A **strong** element"}}
    }

    json =
      conn
      |> json_response(201)

    id =
      json["data"]["id"]
      |> String.to_integer

    assert id

    attributes = json["data"]["attributes"]

    assert attributes["body"] == "<p>A <strong>strong</strong> element</p>\n"
    assert attributes["markdown"] == "A **strong** element"

    preview =
      Preview
      |> Repo.get!(id)

    assert preview.body == "<p>A <strong>strong</strong> element</p>\n"
    assert preview.markdown == "A **strong** element"
  end

  test "it assigns current user as owner of preview, if available", %{conn: conn} do
    user = insert(:user)

    path = preview_path(conn, :create)
    payload = %{
      "meta" => %{},
      "data" => %{"type" => "preview", "attributes" => %{markdown: "A **strong** element"}}
    }

    conn =
      conn
      |> Guardian.Plug.api_sign_in(user)
      |> post(path, payload)

    json =
      conn
      |> json_response(201)

    id =
      json["data"]["id"]
      |> String.to_integer

    preview =
      Preview
      |> Repo.get!(id)

    assert preview.user_id == user.id
  end
end
