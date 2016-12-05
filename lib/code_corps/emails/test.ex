defmodule CodeCorps.Emails.Test do
  import Bamboo.Email

  def hello_world do
    new_email
    |> to("test_user@codecorps.org")
    |> from("admin@codecorps.org")
    |> subject("Hello World!")
    |> html_body("<strong>Hello</strong> World!")
    |> text_body("Hello World!")
  end
end
