defmodule Bacen.STA.XMLMiddlewareTest do
  use Bacen.STA.EctoCase

  import Bacen.STA.XMLMiddleware

  alias Bacen.STA.ProtocolSerializer
  alias Tesla.Env

  describe "call/1" do
    test "sends without encoding, decodes on response" do
      protocol = build(:protocol)

      assert {:ok, xml} = ProtocolSerializer.serialize(protocol)
      parsed_xml = Quinn.parse(xml)

      assert {:ok, %Env{body: ^parsed_xml}} = call(%Env{body: xml}, [], [])
    end

    test "encodes and decodes" do
      tuple_xml = {:Test, [{:Key, ['value']}]}
      parsed_xml = [%{attr: [], name: :Test, value: [%{attr: [], name: :Key, value: ["value"]}]}]

      assert {:ok, %Env{body: ^parsed_xml}} = call(%Env{body: tuple_xml}, [], [])
    end
  end

  describe "Client" do
    defmodule Client do
      @moduledoc false
      use Tesla

      plug Bacen.STA.XMLMiddleware

      adapter fn env ->
        case env.url do
          "/error" ->
            {:error, %{env | body: "error"}}

          _ ->
            {:ok, env}
        end
      end
    end

    test "return error when decoding" do
      assert {:error, %Env{body: "error"}} = Client.get("/error")
    end
  end
end
