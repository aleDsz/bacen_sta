defmodule Bacen.STA.Protocol do
  @moduledoc """
  The protocol message schema for Sisbacen's server.

  This message is responsible to create a new protocol
  into Sisbacen's server to allow the application to send
  one of the ACCS/CCS messages for given protocol.

  It has the following XML examples:

  ```xml
  <Parametros>
    <IdentificadorDocumento>ACCS001</IdentificadorDocumento>
    <Hash>1235345hfdsahgdasd214312</Hash>
    <Tamanho>1234</Tamanho>
    <NomeArquivo>202105072230.xml</NomeArquivo>
    <Observacao />
  </Parametros>
  ```

  ```xml
  <Parametros>
    <IdentificadorDocumento>ACCS001</IdentificadorDocumento>
    <Hash>1235345hfdsahgdasd214312</Hash>
    <Tamanho>1234</Tamanho>
    <NomeArquivo>202105072230.xml</NomeArquivo>
    <Observacao>bla bla bla</Observacao>
  </Parametros>
  ```

  ```xml
  <Parametros>
    <IdentificadorDocumento>ACCS001</IdentificadorDocumento>
    <Hash>1235345hfdsahgdasd214312</Hash>
    <Tamanho>1234</Tamanho>
    <NomeArquivo>202105072230.xml</NomeArquivo>
    <Observacao>bla bla bla</Observacao>
    <Destinatarios>
      <Destinatario>
        <Unidade>12345</Unidade>
        <Dependencia>dependencia 1</Dependencia>
        <Operador>operador 1</Operador>
      </Destinatario>
    </Destinatarios>
  </Parametros>
  ```
  """
  use Ecto.Schema

  import Ecto.Changeset

  @typedoc """
  The Bacen's CCS protocol type
  """
  @type t :: %__MODULE__{}

  @parameters_fields ~w(file_type hash file_size file_name observation)a
  @parameters_required_fields ~w(file_type hash file_size file_name)a

  @sender_fields ~w(unity dependency operator)a

  @primary_key false
  embedded_schema do
    embeds_one :parameters, Parameters, primary_key: false, source: :Parametros do
      field :file_type, :string, source: :IdentificadorDocumento
      field :hash, :string, source: :Hash
      field :file_size, :integer, source: :Tamanho
      field :file_name, :string, source: :NomeArquivo
      field :observation, :string, source: :Observacao

      embeds_one :senders, Senders, primary_key: false, source: :Destinatarios do
        embeds_many :sender, Sender, primary_key: false, source: :Destinatario do
          field :unity, :string, source: :Unidade
          field :dependency, :string, source: :Dependencia
          field :operator, :string, source: :Operador
        end
      end
    end
  end

  @doc """
  Create new valid protocol xml from given attributes
  """
  @spec new(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def new(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end

  @doc false
  def changeset(schema = %__MODULE__{}, attrs) when is_map(attrs) do
    schema
    |> cast(attrs, [])
    |> cast_embed(:parameters, with: &parameters_changeset/2, required: true)
  end

  @doc false
  def parameters_changeset(parameters, attrs) when is_map(attrs) do
    parameters
    |> cast(attrs, @parameters_fields)
    |> validate_required(@parameters_required_fields)
    |> validate_length(:hash, is: 64)
    |> cast_embed(:senders, with: &senders_changeset/2)
  end

  @doc false
  def senders_changeset(senders, attrs) when is_map(attrs) do
    senders
    |> cast(attrs, [])
    |> cast_embed(:sender, with: &sender_changeset/2)
  end

  @doc false
  def sender_changeset(sender, attrs) when is_map(attrs) do
    sender
    |> cast(attrs, @sender_fields)
    |> validate_required(@sender_fields)
  end
end
