defmodule Hstorex.Decoder do

  @moduledoc """
  Converts from Postgres Hstore binary format and Elixir Maps 
  
      Hstorex.Decoder.decode(<<0, 0, 0, 1, 0, 0, 0, 1, 107, 0, 0, 0, 1, 118>>)
      %{"k" => "v"}
  """

  @doc """
  Takes a binary representation of an Hstore and returns an Elixir Map
  """
  def decode(<< count::integer-big-size(32), binary::binary >>) do
    decode binary, count
  end
  def decode(_), do: :error

  defp decode(binary, count), do: decode(binary, count, %{})
  defp decode(binary, 0, map), do: map
  defp decode(binary, count, map) do
    {key, value, binary} = decode_kvp(binary)
    map = Dict.put(map, key, value)
    decode(binary, count-1, map)
  end

  defp decode_kvp(binary) do
    {key, binary} = decode_text(binary)
    {value, binary} = decode_text(binary)
    {key, value, binary}
  end

  defp decode_text(<<255,255,255,255, binary::binary>>), do: {nil, binary}
  defp decode_text(binary) do
    << char_count::integer-big-size(32), binary::binary >> = binary
    << text::binary-size(char_count), binary::binary>> = binary
    {text, binary}
  end
end
