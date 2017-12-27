defmodule CodeCorps.Emails.BaseEmailTest do
  use CodeCorps.ModelCase
  use Bamboo.Test
  alias CodeCorps.Emails.BaseEmail

  describe "get_name/1" do
    test "get_name returns there on nil name" do
      user = %CodeCorps.User{}
      assert BaseEmail.get_name(user) == "there"
    end

    test "get_name returns first_name of user" do
      user = %CodeCorps.User{first_name: "Zacck"}
      assert BaseEmail.get_name(user) == "Zacck"
    end
  end
end
