defmodule Bacen.STA.ResponseTest do
  use Bacen.STA.EctoCase

  import Bacen.STA.Response

  describe "new/0" do
    test "builds a Response message" do
      attrs = params_for(:response)

      assert {:ok,
              %Bacen.STA.Response{
                result: %Bacen.STA.Response.Result{protocol: "053c29ae8b82"}
              }} == new(attrs)
    end
  end

  describe "Response" do
    alias Bacen.STA.Response

    test "validates the existence of parameters field" do
      changeset = refute_valid_changeset changeset(%Response{}, %{})
      assert "can't be blank" in errors_on(changeset).result
    end
  end

  describe "Parameters" do
    alias Bacen.STA.Response.Result

    test "validates the existence of protocol field" do
      changeset = refute_valid_changeset result_changeset(%Result{}, %{})
      assert "can't be blank" in errors_on(changeset).protocol
    end
  end
end
