defmodule CodeCorps.MailerTest do
  @moduledoc false
  
  use ExUnit.Case
  use Bamboo.Test

  alias CodeCorps.{Emails, Mailer}

  test "hello_world email works" do
    email = Emails.Test.hello_world

    assert email.to == "test_user@codecorps.org"
    assert email.from == "admin@codecorps.org"
    assert email.subject == "Hello World!"
    assert email.html_body == "<strong>Hello</strong> World!"
    assert email.text_body == "Hello World!"
  end

  test "email can be sent" do
    email = Emails.Test.hello_world
    email |> Mailer.deliver_now

    assert_delivered_email email
  end
end
