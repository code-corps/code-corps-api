defmodule CodeCorps.PreviewControllerTest do
  use CodeCorps.ApiCase

  alias CodeCorps.Preview

  defp build_payload do
    %{"data" => %{"type" => "preview","attributes" => %{markdown: "A **strong** element"}}}
  end

  describe "create" do
    @tag :authenticated
    test "creates and renders resource, with body containing markdown rendered to html", %{conn: conn} do
      payload = build_payload
      path = conn |> preview_path(:create)
      json = conn |> post(path, payload) |> json_response(201)

      id = json["data"]["id"] |> String.to_integer

      assert id

      attributes = json["data"]["attributes"]

      assert attributes["body"] == "<p>A <strong>strong</strong> element</p>\n"
      assert attributes["markdown"] == "A **strong** element"

      preview = Preview |> Repo.get!(id)

      assert preview.body == "<p>A <strong>strong</strong> element</p>\n"
      assert preview.markdown == "A **strong** element"
    end

    @tag :authenticated
    test "it assigns current user as owner of preview, if available", %{conn: conn, current_user: current_user} do
      payload = build_payload
      path = conn |> preview_path(:create)
      json = conn |> post(path, payload) |> json_response(201)


      id = json["data"]["id"] |> String.to_integer

      preview = Preview |> Repo.get!(id)

      assert preview.user_id == current_user.id
    end

    test "does not create resource, and responds with 401 when unauthenticated", %{conn: conn} do
      payload = build_payload
      path = conn |> preview_path(:create)
      assert conn |> post(path, payload) |> json_response(401)
    end
  end

end
