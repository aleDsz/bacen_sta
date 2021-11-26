defmodule Bacen.STA do
  @moduledoc """
  # Sistema de Transferência de Arquivos

  The STA context.

  It communicates with Bacen's STA (Sisbacen) WebService.
  """

  alias Bacen.STA.{Protocol, ProtocolParser, ProtocolSerializer, Response}

  @client Application.compile_env(:bacen_sta, :client, Bacen.STA.HTTP)

  @doc """
  Checks if system is defined to use the staging server

  ## Examples

      iex> Application.put_env(:bacen_sta, :test_mode, true)
      iex> Bacen.STA.test?()
      true

      iex> Application.put_env(:bacen_sta, :test_mode, false)
      iex> Bacen.STA.test?()
      false

  """
  @spec test?() :: boolean()
  def test? do
    Application.get_env(:bacen_sta, :test_mode, false)
  end

  @doc """
  Creates a new protocol and sends it to Bacen's STA WebService.

  ## Examples

      iex> attrs = %{
      iex>   parameters: %{
      iex>     file_size: 1234,
      iex>     file_name: "foo",
      iex>     file_type: "ACCS001",
      iex>     hash: "053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443"
      iex>   }
      iex> }
      iex> Mox.stub_with(Bacen.STA.ClientMock, FakeBacenSTA)
      iex> Bacen.STA.create_protocol(attrs)
      {:ok, "123456789"}

      iex> attrs = %{
      iex>   parameters: %{
      iex>     file_size: 1234,
      iex>     file_name: "invalid_xml",
      iex>     file_type: "ACCS001",
      iex>     hash: "053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443"
      iex>   }
      iex> }
      iex> Mox.stub_with(Bacen.STA.ClientMock, FakeBacenSTA)
      iex> Bacen.STA.create_protocol(attrs)
      {:error, :invalid_xml}

      iex> attrs = %{
      iex>   parameters: %{
      iex>     file_size: 1234,
      iex>     file_name: "error",
      iex>     file_type: "ACCS001",
      iex>     hash: "053c29ae8b823df65f5bff084f410ca70530c30112bc7590518fe421f4421443"
      iex>   }
      iex> }
      iex> Mox.stub_with(Bacen.STA.ClientMock, FakeBacenSTA)
      iex> Bacen.STA.create_protocol(attrs)
      {:error, [%{attr: [], name: :Resultado, value: [%{attr: [], name: :Erro, value: ["bad request"]}]}]}

  """
  @spec create_protocol(map()) :: {:ok, String.t()} | {:error, any()}
  def create_protocol(attrs) when is_map(attrs) do
    with {:ok, protocol} <- Protocol.new(attrs),
         {:ok, protocol_xml} <- ProtocolSerializer.serialize(protocol),
         {:ok, body} <- @client.send_protocol(protocol_xml),
         {:ok, %Response{result: %Response.Result{protocol: protocol_number}}} <-
           ProtocolParser.parse(body) do
      {:ok, protocol_number}
    end
  end

  @doc """
  Sends a file content for given protocol number to Bacen's STA WebService.

  ## Examples

      iex> Mox.stub_with(Bacen.STA.ClientMock, FakeBacenSTA)
      iex> Bacen.STA.send_file_content("123456789", "some long file content")
      :ok

      iex> Mox.stub_with(Bacen.STA.ClientMock, FakeBacenSTA)
      iex> Bacen.STA.send_file_content("123456789", "wrong file content")
      {:error, [%{attr: [], name: :Resultado, value: [%{attr: [], name: :Erro, value: ["bad request"]}]}]}

  """
  @spec send_file_content(String.t(), String.t()) :: :ok | {:error, any()}
  def send_file_content(protocol_number, file_content)
      when is_binary(protocol_number) and is_binary(file_content) do
    @client.send_file_content(protocol_number, file_content)
  end
end
