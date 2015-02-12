defmodule Hstorex.Encoder do

  @moduledoc """
  Converts from Postgres Hstore binary format and Elixir Maps 
  
      map = Hstorex.Encoder.encode(%{"k" => "v"})
      <<0, 0, 0, 1, 0, 0, 0, 1, 107, 0, 0, 0, 1, 118>>
  """

  @doc """
  Takes an Elixir Map and returns the binary representation of an Hstore.
  """
  def encode(map) when is_map(map) do
    kvps = Enum.to_list(map)
    encode_integer(Enum.count(kvps)) <> encode_kvp("", kvps)
  end
  def encode(_), do: :error

  defp encode_kvp(binary, []), do: binary
  defp encode_kvp(binary, [{key, value}|tail]) do
    encode_kvp(binary <> encode_text(key) <> encode_text(value), tail)
  end

  defp encode_text(text) when is_nil(text), do: <<255,255,255,255>>
  defp encode_text(text) when is_binary(text), do: encode_length(text) <> text
  defp encode_text(text) when is_atom(text), do: encode_text(to_string(text))
  defp encode_text(text), do: encode_text(inspect(text))

  defp encode_length(text) when is_binary(text), do: encode_integer(byte_size(text))

  defp encode_integer(int) when is_integer(int), do: << int::integer-big-size(32) >>
end
