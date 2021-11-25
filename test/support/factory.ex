defmodule Bacen.STA.TestRepo do
  @moduledoc false
end

defmodule Bacen.STA.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Bacen.STA.TestRepo

  def protocol_factory do
    %Bacen.STA.Protocol{
      parameters: build(:parameters)
    }
  end

  def parameters_factory do
    datetime =
      "America/Sao_Paulo"
      |> Timex.now()
      |> Timex.format!("{YYYY}{0M}{0D}{h24}{m}")

    file_name = "#{datetime}.xml"

    content =
      ~s(\0<\0?\0x\0m\0l\0 \0v\0e\0r\0s\0i\0o\0n\0=\0\"\01\0.\00\0\"\0?\0>\0<\0C\0C\0S\0D\0O\0C\0 \0x\0m\0l\0n\0s\0=\0\"\0h\0t\0t\0p\0:\0/\0/\0w\0w\0w\0.\0b\0c\0b\0.\0g\0o\0v\0.\0b\0r\0/\0c\0c\0s\0/\0A\0C\0C\0S\00\00\02\0.\0x\0s\0d\0\"\0>\0<\0B\0C\0A\0R\0Q\0>\0<\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\06\09\09\03\00\08\04\06\0<\0/\0I\0d\0e\0n\0t\0d\0E\0m\0i\0s\0s\0o\0r\0>\0<\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\02\05\09\09\02\09\09\00\0<\0/\0I\0d\0e\0n\0t\0d\0D\0e\0s\0t\0i\0n\0a\0t\0a\0r\0i\0o\0>\0<\0N\0o\0m\0A\0r\0q\0>\0A\0C\0C\0S\00\00\02\0<\0/\0N\0o\0m\0A\0r\0q\0>\0<\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0/\0B\0C\0A\0R\0Q\0>\0<\0S\0I\0S\0A\0R\0Q\0>\0<\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0S\0i\0t\0A\0r\0q\0>\0A\0<\0/\0S\0i\0t\0A\0r\0q\0>\0<\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\00\00\00\00\00\00\00\00\00\00\00\00\0<\0/\0U\0l\0t\0N\0u\0m\0R\0e\0m\0e\0s\0s\0a\0A\0r\0q\0>\0<\0D\0t\0H\0r\0B\0C\0>\02\00\02\01\0-\00\05\0-\00\07\0T\00\05\0:\00\04\0:\00\00\0<\0/\0D\0t\0H\0r\0B\0C\0>\0<\0D\0t\0M\0o\0v\0t\0o\0>\02\00\02\01\0-\00\05\0-\00\07\0<\0/\0D\0t\0M\0o\0v\0t\0o\0>\0<\0/\0C\0C\0S\0A\0r\0q\0A\0t\0l\0z\0D\0i\0a\0r\0i\0a\0R\0e\0s\0p\0A\0r\0q\0>\0<\0/\0S\0I\0S\0A\0R\0Q\0>\0<\0/\0C\0C\0S\0D\0O\0C\0>)

    hash =
      :sha256
      |> :crypto.hash(content)
      |> Base.encode16()
      |> String.downcase()

    file_size = byte_size(content)

    %Bacen.STA.Protocol.Parameters{
      file_name: file_name,
      file_size: file_size,
      file_type: "ACCS001",
      hash: hash,
      observation: nil,
      senders: build(:senders)
    }
  end

  def senders_factory do
    %Bacen.STA.Protocol.Parameters.Senders{
      sender: build_list(1, :sender)
    }
  end

  def sender_factory do
    %Bacen.STA.Protocol.Parameters.Senders.Sender{
      unity: "Unity001",
      dependency: "Dependency001",
      operator: "Operator001"
    }
  end

  def response_factory do
    %Bacen.STA.Response{
      result: build(:result)
    }
  end

  def result_factory do
    %Bacen.STA.Response.Result{
      protocol: "053c29ae8b82"
    }
  end
end
