defmodule Bacen.STA.HTTPTest do
  use Bacen.STA.EctoCase

  import Tesla.Mock

  alias Bacen.STA.{HTTP, ProtocolParser, ProtocolSerializer, Response, XMLMiddleware}

  describe "send_protocol/1" do
    test "returns new protocol" do
      protocol = build(:protocol)
      response = build_response("123456789")

      assert {:ok, xml} = ProtocolSerializer.serialize(protocol)

      mock(fn %{url: "https://sta-h.bcb.gov.br/staws/arquivos", method: :post, body: ^xml} ->
        response
        |> build_xml()
        |> text(status: 200)
      end)

      assert {:ok, response} = HTTP.send_protocol(xml)

      assert {:ok, %Response{result: %Response.Result{protocol: "123456789"}}} =
               ProtocolParser.parse(response)
    end

    test "returns api error" do
      protocol = build(:protocol)

      assert {:ok, xml} = ProtocolSerializer.serialize(protocol)

      mock(fn %{url: "https://sta-h.bcb.gov.br/staws/arquivos", method: :post, body: ^xml} ->
        text(~s(<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Erro>bad request</Erro>),
          status: 400
        )
      end)

      assert {:error, [%{attr: [], name: :Erro, value: ["bad request"]}]} ==
               HTTP.send_protocol(xml)
    end

    test "returns tesla error" do
      protocol = build(:protocol)

      assert {:ok, xml} = ProtocolSerializer.serialize(protocol)

      mock(fn %{url: "https://sta-h.bcb.gov.br/staws/arquivos", method: :post, body: ^xml} ->
        {:error, :timeout}
      end)

      assert {:error, :timeout} == HTTP.send_protocol(xml)
    end
  end

  describe "send_file_content/2" do
    test "sends file content successfully" do
      protocol = "123456789"

      file_content =
        ~s(\0<\0?\0x\0m\0l\0 \0v\0e\0r\0s\0i\0o\0n\0=\0\"\01\0.\00\0\"\0?\0>\0<\0C\0C\0S\0D\0O\0C\0 \0x\0m\0l\0n\0s\0=\0\"\0h\0t\0t\0p\0:\0/\0/\0w\0w\0w\0.\0b\0c\0b\0.\0g\0o\0v\0.\0b\0r\0/\0c\0c\0s\0/\0A\0C\0C\0S\00\00\02\0.\0x\0s\0d\0\"\0>\0<\0B\0C\0A\0R\0Q\0>\0<\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\06\09\09\03\00\08\04\06\0<\0/\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\0<\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\02\05\09\09\02\09\09\00\0<\0/\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\0<\0N\0o\0m\0A\0r\0q\0>\0A\0C\0C\0S\00\00\02\0<\0/\0N\0o\0m\0A\0r\0q\0>\0<\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0/\0B\0C\0A\0R\0Q\0>\0<\0S\0I\0S\0A\0R\0Q\0>\0<\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0S\0i\0t\0A\0r\0q\0>\0A\0<\0/\0S\0i\0t\0A\0r\0q\0>\0<\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0D\0t\0H\0r\0B\0C\0>\02\00\02\01\0-\00\05\0-\00\07\0T\00\05\0:\00\04\0:\00\00\0<\0/\0D\0t\0H\0r\0B\0C\0>\0<\0D\0t\0M\0o\0v\0t\0o\0>\02\00\02\01\0-\00\05\0-\00\07\0<\0/\0D\0t\0M\0o\0v\0t\0o\0>\0<\0/\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0/\0S\0I\0S\0A\0R\0Q\0>\0<\0/\0C\0C\0S\0D\0O\0C\0>)

      mock(fn %{
                url: "https://sta-h.bcb.gov.br/staws/arquivos/123456789/conteudo",
                method: :put,
                body: ^file_content
              } ->
        text(nil, status: 200)
      end)

      assert :ok == HTTP.send_file_content(protocol, file_content)
    end

    test "returns api error" do
      protocol = "123456789"

      file_content =
        ~s(\0<\0?\0x\0m\0l\0 \0v\0e\0r\0s\0i\0o\0n\0=\0\"\01\0.\00\0\"\0?\0>\0<\0C\0C\0S\0D\0O\0C\0 \0x\0m\0l\0n\0s\0=\0\"\0h\0t\0t\0p\0:\0/\0/\0w\0w\0w\0.\0b\0c\0b\0.\0g\0o\0v\0.\0b\0r\0/\0c\0c\0s\0/\0A\0C\0C\0S\00\00\02\0.\0x\0s\0d\0\"\0>\0<\0B\0C\0A\0R\0Q\0>\0<\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\06\09\09\03\00\08\04\06\0<\0/\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\0<\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\02\05\09\09\02\09\09\00\0<\0/\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\0<\0N\0o\0m\0A\0r\0q\0>\0A\0C\0C\0S\00\00\02\0<\0/\0N\0o\0m\0A\0r\0q\0>\0<\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0/\0B\0C\0A\0R\0Q\0>\0<\0S\0I\0S\0A\0R\0Q\0>\0<\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0S\0i\0t\0A\0r\0q\0>\0A\0<\0/\0S\0i\0t\0A\0r\0q\0>\0<\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0D\0t\0H\0r\0B\0C\0>\02\00\02\01\0-\00\05\0-\00\07\0T\00\05\0:\00\04\0:\00\00\0<\0/\0D\0t\0H\0r\0B\0C\0>\0<\0D\0t\0M\0o\0v\0t\0o\0>\02\00\02\01\0-\00\05\0-\00\07\0<\0/\0D\0t\0M\0o\0v\0t\0o\0>\0<\0/\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0/\0S\0I\0S\0A\0R\0Q\0>\0<\0/\0C\0C\0S\0D\0O\0C\0>)

      mock(fn %{
                url: "https://sta-h.bcb.gov.br/staws/arquivos/123456789/conteudo",
                method: :put,
                body: ^file_content
              } ->
        text(~s(<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Erro>bad request</Erro>),
          status: 400
        )
      end)

      assert {:error, [%{attr: [], name: :Erro, value: ["bad request"]}]} ==
               HTTP.send_file_content(protocol, file_content)
    end

    test "returns tesla error" do
      protocol = "123456789"

      file_content =
        ~s(\0<\0?\0x\0m\0l\0 \0v\0e\0r\0s\0i\0o\0n\0=\0\"\01\0.\00\0\"\0?\0>\0<\0C\0C\0S\0D\0O\0C\0 \0x\0m\0l\0n\0s\0=\0\"\0h\0t\0t\0p\0:\0/\0/\0w\0w\0w\0.\0b\0c\0b\0.\0g\0o\0v\0.\0b\0r\0/\0c\0c\0s\0/\0A\0C\0C\0S\00\00\02\0.\0x\0s\0d\0\"\0>\0<\0B\0C\0A\0R\0Q\0>\0<\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\06\09\09\03\00\08\04\06\0<\0/\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\0<\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\02\05\09\09\02\09\09\00\0<\0/\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\0<\0N\0o\0m\0A\0r\0q\0>\0A\0C\0C\0S\00\00\02\0<\0/\0N\0o\0m\0A\0r\0q\0>\0<\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0/\0B\0C\0A\0R\0Q\0>\0<\0S\0I\0S\0A\0R\0Q\0>\0<\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0S\0i\0t\0A\0r\0q\0>\0A\0<\0/\0S\0i\0t\0A\0r\0q\0>\0<\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0D\0t\0H\0r\0B\0C\0>\02\00\02\01\0-\00\05\0-\00\07\0T\00\05\0:\00\04\0:\00\00\0<\0/\0D\0t\0H\0r\0B\0C\0>\0<\0D\0t\0M\0o\0v\0t\0o\0>\02\00\02\01\0-\00\05\0-\00\07\0<\0/\0D\0t\0M\0o\0v\0t\0o\0>\0<\0/\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0/\0S\0I\0S\0A\0R\0Q\0>\0<\0/\0C\0C\0S\0D\0O\0C\0>)

      mock(fn %{
                url: "https://sta-h.bcb.gov.br/staws/arquivos/123456789/conteudo",
                method: :put,
                body: ^file_content
              } ->
        {:error, :timeout}
      end)

      assert {:error, :timeout} == HTTP.send_file_content(protocol, file_content)
    end
  end

  defp build_response(protocol_number) do
    {:Resultado,
     [
       {:Protocolo, [to_charlist(protocol_number)]}
     ]}
  end

  defp build_xml(element) do
    XMLMiddleware.encode(element)
  end
end
