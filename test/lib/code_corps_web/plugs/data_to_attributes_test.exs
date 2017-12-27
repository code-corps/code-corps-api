defmodule CodeCorpsWeb.Plug.DataToAttributesTest do
  use CodeCorpsWeb.ConnCase

  alias CodeCorpsWeb.Plug.DataToAttributes

  test "converts basic JSON API payload to params suitable for Ecto", %{conn: conn} do
    payload = %{
      "id" => "1",
      "data" => %{
        "attributes" => %{"foo" => "bar", "baz" => "bat"},
        "type" => "resource"
      }
    }

    converted_params =
      conn
      |> Map.put(:params, payload)
      |> DataToAttributes.call
      |> Map.get(:params)

    assert converted_params == %{
      "baz" => "bat",
      "foo" => "bar",
      "id" => "1",
      "type" => "resource"
    }
  end

  test "converts belongs_to specified via identifier map into proper id", %{conn: conn} do
    payload = %{
      "id" => "1",
      "data" => %{
        "attributes" => %{"foo" => "bar"},
        "relationships" => %{
          "baz" => %{"data" => %{"id" => "2", "type" => "baz"}}
        },
        "type" => "resource"
      }
    }

    converted_params =
      conn
      |> Map.put(:params, payload)
      |> DataToAttributes.call
      |> Map.get(:params)

    assert converted_params == %{
      "baz_id" => "2",
      "foo" => "bar",
      "id" => "1",
      "type" => "resource"
    }
  end

  test "converts has_many specified via identifier maps into proper ids", %{conn: conn} do
    payload = %{
      "id" => "1",
      "data" => %{
        "attributes" => %{"foo" => "bar"},
        "relationships" => %{
          "baz" => %{"data" => [
            %{"id" => "2", "type" => "baz"},
            %{"id" => "3", "type" => "baz"}
          ]}
        },
        "type" => "resource"
      }
    }

    converted_params =
      conn
      |> Map.put(:params, payload)
      |> DataToAttributes.call
      |> Map.get(:params)

    assert converted_params == %{
      "baz_ids" => ["2", "3"],
      "foo" => "bar",
      "id" => "1",
      "type" => "resource"
    }
  end

  test "converts included belongs_to into proper subpayload", %{conn: conn} do
    payload = %{
      "id" => "1",
      "data" => %{
        "attributes" => %{"foo" => "bar"},
        "type" => "resource"
      },
      "included" => [
        %{"data" => %{"attributes" => %{"baz_foo" => "baz_bar"}, "type" => "baz"}}
      ]
    }

    converted_params =
      conn
      |> Map.put(:params, payload)
      |> DataToAttributes.call
      |> Map.get(:params)

    assert converted_params == %{
      "baz" => %{
        "baz_foo" => "baz_bar",
        "type" => "baz"
      },
      "foo" => "bar",
      "id" => "1",
      "type" => "resource"
    }
  end

  test "converts included has_many into proper subpayload", %{conn: conn} do
    payload = %{
      "id" => "1",
      "data" => %{
        "attributes" => %{"foo" => "bar"},
        "type" => "resource"
      },
      "included" => [
        %{"data" => %{"attributes" => %{"baz_foo" => "baz_bar"}, "type" => "baz"}},
        %{"data" => %{"attributes" => %{"baz_foo_2" => "baz_bar_2"}, "type" => "baz"}}
      ]
    }

    converted_params =
      conn
      |> Map.put(:params, payload)
      |> DataToAttributes.call([includes_many: ["baz"]])
      |> Map.get(:params)

    assert converted_params == %{
      "bazs" => [
        %{"baz_foo" => "baz_bar", "type" => "baz"},
        %{"baz_foo_2" => "baz_bar_2", "type" => "baz"},
      ],
      "foo" => "bar",
      "id" => "1",
      "type" => "resource"
    }
  end
end
