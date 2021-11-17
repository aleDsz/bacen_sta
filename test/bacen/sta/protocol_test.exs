defmodule Bacen.STA.ProtocolTest do
  use Bacen.STA.EctoCase

  import Bacen.STA.Protocol

  describe "new/0" do
    test "builds a Protocol message" do
      parameters = params_for(:parameters, file_name: "202111172051.xml", observation: "test")
      attrs = params_for(:protocol, parameters: parameters)

      assert {:ok,
              %Bacen.STA.Protocol{
                parameters: %Bacen.STA.Protocol.Parameters{
                  file_name: "202111172051.xml",
                  file_size: 908,
                  file_type: "ACCS001",
                  hash: "053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443",
                  observation: "test",
                  senders: %Bacen.STA.Protocol.Parameters.Senders{
                    sender: [
                      %Bacen.STA.Protocol.Parameters.Senders.Sender{
                        dependency: "Dependency001",
                        operator: "Operator001",
                        unity: "Unity001"
                      }
                    ]
                  }
                }
              }} == new(attrs)
    end
  end

  describe "Protocol" do
    alias Bacen.STA.Protocol

    test "validates the existence of parameters field" do
      changeset = refute_valid_changeset changeset(%Protocol{}, %{})
      assert "can't be blank" in errors_on(changeset).parameters
    end
  end

  describe "Parameters" do
    alias Bacen.STA.Protocol.Parameters

    test "validates the existence of fields" do
      changeset = refute_valid_changeset parameters_changeset(%Parameters{}, %{})

      assert errors_on(changeset) == %{
               file_name: ["can't be blank"],
               file_size: ["can't be blank"],
               file_type: ["can't be blank"],
               hash: ["can't be blank"]
             }
    end

    test "validates the hash field length" do
      attrs = params_for(:parameters, hash: "123456")
      changeset = refute_valid_changeset parameters_changeset(%Parameters{}, attrs)

      assert "should be 64 character(s)" in errors_on(changeset).hash
    end
  end

  describe "Sender" do
    alias Bacen.STA.Protocol.Parameters.Senders.Sender

    test "validates the existence of fields" do
      changeset = refute_valid_changeset sender_changeset(%Sender{}, %{})

      assert errors_on(changeset) == %{
               unity: ["can't be blank"],
               dependency: ["can't be blank"],
               operator: ["can't be blank"]
             }
    end
  end
end
