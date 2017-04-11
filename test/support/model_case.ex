defmodule CodeCorps.ModelCase do
  @moduledoc """
  This module defines the test case to be used by
  model tests.

  You may define functions here to be used as helpers in
  your model tests. See `errors_on/2`'s definition as reference.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias CodeCorps.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import CodeCorps.Factories
      import CodeCorps.ModelCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CodeCorps.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CodeCorps.Repo, {:shared, self()})
    end

    :ok
  end

  @doc """
  Helper for returning list of errors in a struct when given certain data.

  ## Examples

  Given a User schema that lists `:name` as a required field and validates
  `:password` to be safe, it would return:

      iex> errors_on(%User{}, %{password: "password"})
      [password: "is unsafe", name: "is blank"]

  You could then write your assertion like:

      assert {:password, "is unsafe"} in errors_on(%User{}, %{password: "password"})

  You can also create the changeset manually and retrieve the errors
  field directly:

      iex> changeset = User.changeset(%User{}, password: "password")
      iex> {:password, "is unsafe"} in changeset.errors
      true
  """
  def errors_on(struct, data) do
    struct.__struct__.changeset(struct, data)
    |> Ecto.Changeset.traverse_errors(&CodeCorps.Web.ErrorHelpers.translate_error/1)
    |> Enum.flat_map(fn {key, errors} -> for msg <- errors, do: {key, msg} end)
  end

  @doc """
  Asserts if a specific error message has been added to a specific field on the
  changeset. It is more flexible to use `error_message/2` directly instead of
  this one.

  ```
  assert_error_message(changeset, :foo, "bar")
  ```

  Compared to

  ```
  assert error_message(changeset, :foo) ==  "bar"
  refute error_message?(changeset, :foo) ==  "baz"
  ```
  """
  def assert_error_message(changeset, field, expected_message) do
    assert error_message(changeset, field) == expected_message
  end

  @doc """
  Asserts if a specific validation type has been triggered on a specific field
  on the changeset. It is more flexible to use `validation_triggered/2` directly
  instead of this one.

  ```
  assert_validation_triggered(changeset, :foo, "bar")
  ```

  Compared to

  ```
  assert validation_triggered(changeset, :foo) ==  :required
  refute validation_triggered?(changeset, :bar) ==  :required
  ```
  """
  def assert_validation_triggered(changeset, field, type) do
    assert validation_triggered(changeset, field) == type
  end

  @doc """
  Returns an error message on a specific field on the specified changeset
  """
  @spec error_message(Ecto.Changeset.t, Atom.t) :: String.t
  def error_message(changeset, field) do
    {message, _} = changeset.errors[field]
    message
  end

  @doc """
  Returns an atom indicating the type of validation that was triggered on a
  field in a changeset.
  """
  @spec validation_triggered(Ecto.Changeset.t, Atom.t) :: Atom.t
  def validation_triggered(changeset, field) do
    {_message, status} = changeset.errors[field]
    status[:validation]
  end

  @doc """
  Returns true or false depending on if an assoc_constraint validation has been
  triggered in the provided changeset on the specified field.
  """
  @spec assoc_constraint_triggered?(Ecto.Changeset.t, Atom.t) :: boolean
  def assoc_constraint_triggered?(changeset, field) do
    error_message(changeset, field) == "does not exist"
  end
end
