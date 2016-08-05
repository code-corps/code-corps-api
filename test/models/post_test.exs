defmodule CodeCorps.PostTest do
  use CodeCorps.ModelCase

  alias CodeCorps.Post

  @valid_attrs %{body: "some content", markdown: "some content", number: 42, post_type: "some content", title: "some content"}

  test "changeset with valid attributes" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with no number fails" do
    changeset = Post.changeset(%Post{}, Map.delete(@valid_attrs, :number))
    refute changeset.valid?
  end

  test "changeset with no title fails" do
    changeset = Post.changeset(%Post{}, Map.delete(@valid_attrs, :title))
    refute changeset.valid?
  end

  test "changeset with no body fails" do
    changeset = Post.changeset(%Post{}, Map.delete(@valid_attrs, :body))
    refute changeset.valid?
  end

  test "changeset with no markdown fails" do
    changeset = Post.changeset(%Post{}, Map.delete(@valid_attrs, :markdown))
    refute changeset.valid?
  end

  test "changeset with no post_type fails" do
    changeset = Post.changeset(%Post{}, Map.delete(@valid_attrs, :post_type))
    refute changeset.valid?
  end

  test "changeset validates uniqueness of number" do
    %Post{}
      |> Post.changeset(@valid_attrs)
      |> CodeCorps.Repo.insert!
    post2 = 
      %Post{}
      |> Post.changeset(@valid_attrs)
    assert {:error, changeset} = CodeCorps.Repo.insert(post2)
  end
end
