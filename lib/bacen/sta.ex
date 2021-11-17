defmodule Bacen.STA do
  @moduledoc """
  # Sistema de Transferência de Arquivos

  The STA context.

  It communicates with Bacen's STA (Sisbacen) WebService.
  """

  @doc """
  Checks if system is defined to use the staging server

  ## Examples

      iex> Bacen.STA.test?()
      false

  """
  @spec test?() :: boolean()
  def test? do
    Application.get_env(:bacen_sta, :test_mode, false)
  end
end
