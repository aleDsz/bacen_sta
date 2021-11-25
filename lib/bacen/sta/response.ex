defmodule Bacen.STA.Response do
  @moduledoc """
  The response message schema for Sisbacen's server.

  It represents the `Protocol` xml response from
  Bacen's STA system.

  It has the following XML example:

  ```xml
  <Resultado xmlns:atom="http://www.w3.org/2005/Atom">
    <Protocolo>{protocolo}</Protocolo>
    <atom:link href="https://{host}/staws/arquivos/{protocolo}/conteudo" rel="conteudo" type="application/octet-stream" />
  </Resultado>
  ```
  """
  use Ecto.Schema

  import Ecto.Changeset

  @typedoc """
  The Bacen's CCS protocol response type
  """
  @type t :: %__MODULE__{}

  @result_fields ~w(protocol)a

  @primary_key false
  embedded_schema do
    embeds_one :result, Result, primary_key: false, source: :Resultado do
      field :protocol, :string, source: :Protocolo
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
    |> cast_embed(:result, with: &result_changeset/2, required: true)
  end

  @doc false
  def result_changeset(result, attrs) when is_map(attrs) do
    result
    |> cast(attrs, @result_fields)
    |> validate_required(@result_fields)
  end
end
