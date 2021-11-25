defmodule Bacen.STA.ProtocolSerializer do
  @moduledoc """
  The Protocol message serializer.
  """
  alias Bacen.STA.Protocol

  @doc """
  Serliazes a Protocol message schema into tuple-formatted XML.

  ## Examples

      iex> protocol = %Bacen.STA.Protocol{
      iex>   parameters: %Bacen.STA.Protocol.Parameters{
      iex>     file_name: "202111172051.xml",
      iex>     file_size: 908,
      iex>     file_type: "ACCS001",
      iex>     hash: "053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443",
      iex>     observation: "test",
      iex>     senders: %Bacen.STA.Protocol.Parameters.Senders{
      iex>       sender: [
      iex>         %Bacen.STA.Protocol.Parameters.Senders.Sender{
      iex>           dependency: "Dependency001",
      iex>           operator: "Operator001",
      iex>           unity: "Unity001"
      iex>         }
      iex>       ]
      iex>     }
      iex>   }
      iex> }
      iex> Bacen.STA.ProtocolSerializer.serialize(protocol)
      {:ok, ~s(<?xml version="1.0"?><Parametros><IdentificadorDocumento>ACCS001</IdentificadorDocumento><Hash>053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443</Hash><Tamanho>908</Tamanho><NomeArquivo>202111172051.xml</NomeArquivo><Observacao>test</Observacao><Destinatarios><Destinatario><Unidade>Unity001</Unidade><Dependencia>Dependency001</Dependencia><Operador>Operator001</Operador></Destinatario></Destinatarios></Parametros>)}

      iex> protocol = %Bacen.STA.Protocol{
      iex>   parameters: %Bacen.STA.Protocol.Parameters{
      iex>     file_name: "202111172051.xml",
      iex>     file_size: 908,
      iex>     file_type: "ACCS001",
      iex>     hash: "053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443",
      iex>     observation: nil,
      iex>     senders: %Bacen.STA.Protocol.Parameters.Senders{
      iex>       sender: [
      iex>         %Bacen.STA.Protocol.Parameters.Senders.Sender{
      iex>           dependency: "Dependency001",
      iex>           operator: "Operator001",
      iex>           unity: "Unity001"
      iex>         }
      iex>       ]
      iex>     }
      iex>   }
      iex> }
      iex> Bacen.STA.ProtocolSerializer.serialize(protocol)
      {:ok, ~s(<?xml version="1.0"?><Parametros><IdentificadorDocumento>ACCS001</IdentificadorDocumento><Hash>053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443</Hash><Tamanho>908</Tamanho><NomeArquivo>202111172051.xml</NomeArquivo><Observacao/><Destinatarios><Destinatario><Unidade>Unity001</Unidade><Dependencia>Dependency001</Dependencia><Operador>Operator001</Operador></Destinatario></Destinatarios></Parametros>)}

      iex> protocol = %Bacen.STA.Protocol{
      iex>   parameters: %Bacen.STA.Protocol.Parameters{
      iex>     file_name: "202111172051.xml",
      iex>     file_size: 908,
      iex>     file_type: "ACCS001",
      iex>     hash: "053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443",
      iex>     observation: nil,
      iex>     senders: %Bacen.STA.Protocol.Parameters.Senders{sender: []}
      iex>   }
      iex> }
      iex> Bacen.STA.ProtocolSerializer.serialize(protocol)
      {:ok, ~s(<?xml version="1.0"?><Parametros><IdentificadorDocumento>ACCS001</IdentificadorDocumento><Hash>053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443</Hash><Tamanho>908</Tamanho><NomeArquivo>202111172051.xml</NomeArquivo><Observacao/><Destinatarios/></Parametros>)}

      iex> protocol = %Bacen.STA.Protocol{parameters: %Bacen.STA.Protocol.Parameters{}}
      iex> Bacen.STA.ProtocolSerializer.serialize(protocol)
      {:error, :invalid_parameters}

      iex> protocol = %Bacen.STA.Protocol{}
      iex> Bacen.STA.ProtocolSerializer.serialize(protocol)
      {:error, :invalid_protocol}

  """
  def serialize(%Protocol{parameters: parameters = %Protocol.Parameters{}}) do
    string_xml =
      parameters
      |> build_element()
      |> List.wrap()
      |> :xmerl.export_simple(:xmerl_xml)
      |> List.flatten()
      |> to_string()

    {:ok, string_xml}
  rescue
    _ -> {:error, :invalid_parameters}
  end

  def serialize(_), do: {:error, :invalid_protocol}

  defp build_element(parameters = %Protocol.Parameters{}) do
    {:Parametros,
     [
       {:IdentificadorDocumento, [to_charlist(parameters.file_type)]},
       {:Hash, [to_charlist(parameters.hash)]},
       {:Tamanho, file_size(parameters.file_size)},
       {:NomeArquivo, [to_charlist(parameters.file_name)]},
       {:Observacao, observation(parameters)},
       {:Destinatarios, senders(parameters)}
     ]}
  end

  defp file_size(size) when is_integer(size) do
    size =
      size
      |> to_string()
      |> to_charlist()

    [size]
  end

  defp observation(%Protocol.Parameters{observation: nil}), do: []
  defp observation(%Protocol.Parameters{observation: observation}), do: [to_charlist(observation)]

  defp senders(%Protocol.Parameters{
         senders: %Protocol.Parameters.Senders{sender: senders = [_ | _]}
       }) do
    Enum.map(senders, fn sender = %Protocol.Parameters.Senders.Sender{} ->
      {:Destinatario,
       [
         {:Unidade, [to_charlist(sender.unity)]},
         {:Dependencia, [to_charlist(sender.dependency)]},
         {:Operador, [to_charlist(sender.operator)]}
       ]}
    end)
  end

  defp senders(%Protocol.Parameters{senders: _}),
    do: []
end
