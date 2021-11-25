defmodule Bacen.STA.ProtocolParser do
  @moduledoc """
  The Protocol response message parser.
  """

  alias Bacen.STA.Response

  @typep xml_node :: %{attr: keyword(), name: atom(), value: list(any())}
  @typep xml_nodes :: list(xml_node())

  @doc """
  Parses a Protocol response message schema into tuple-formatted XML.

  ## Examples

      iex> response_xml = ~s(<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Resultado xmlns:atom="http://www.w3.org/2005/Atom"><Protocolo>202111172051</Protocolo><atom:link href="https://sta-h.bcb.gov.br/staws/arquivos/202111172051/conteudo" rel="conteudo" type="application/octet-stream" /></Resultado>)
      iex> Bacen.STA.ProtocolParser.parse(response_xml)
      {:ok, %Bacen.STA.Response{
        result: %Bacen.STA.Response.Result{protocol: "202111172051"}
      }}

  """
  @spec parse(String.t() | xml_nodes()) :: {:ok, Response.t()} | {:error, any()}
  def parse(xml = "<?xml version" <> _) do
    xml
    |> Quinn.parse()
    |> parse_to_schema()
  end

  def parse(parsed_xml) when is_list(parsed_xml) do
    parse_to_schema(parsed_xml)
  end

  defp parse_to_schema([]), do: {:error, :invalid_xml}

  defp parse_to_schema(parsed_xml = [%{name: :Resultado}]) do
    case Quinn.find(parsed_xml, :Protocolo) do
      [] -> {:error, :invalid_xml}
      [%{value: [result | _]} | _] -> build_schema(result)
    end
  end

  defp build_schema(protocol_number) do
    Response.new(%{result: %{protocol: protocol_number}})
  end
end
