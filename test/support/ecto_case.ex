defmodule Bacen.STA.EctoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      import Bacen.STA.EctoCase
      import Bacen.STA.Factory

      alias Ecto.Changeset
    end
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @doc """
  Assert valid changeset
  """
  defmacro assert_valid_changeset(expression) do
    quote do
      assert changeset = unquote(expression)
      assert changeset.valid?

      changeset
    end
  end

  @doc """
  Refute valid changeset
  """
  defmacro refute_valid_changeset(expression) do
    quote do
      assert changeset = unquote(expression)
      refute changeset.valid?

      changeset
    end
  end
end
