defmodule Ecto.Hstore do
  @moduledoc """
  An Ecto type for Postgres Hstore.
  """

  @doc """
  The Ecto primitive type.
  """
  def type, do: :string

  @doc """
  HStores are blank when given as maps and the maps have no keys.
  """
  defdelegate blank?(value), to: Ecto.Type

  @doc """
  Converts an `Elixir.Map` into an serialized hstore string.
  """
  def dump(map) do
    serialized_hstore = map
     |> Map.to_list
     |> Enum.map(&serialize_kvp/1)
     |> Enum.reject(&is_nil/1)
     |> Enum.join(", ")
    {:ok, serialized_hstore}
  end
  defp serialize_kvp({nil, _}), do: nil
  defp serialize_kvp({key, nil}), do: "\"#{escape(key)}\"=>NULL"
  defp serialize_kvp({key, value}), do: "\"#{escape(key)}\"=>\"#{escape(value)}\""
  
  defp escape(str) when is_binary(str) do
    String.replace(str, ~s("), ~s(\\"))
  end
  defp escape(str) when is_atom(str), do: escape(to_string(str))
  defp escape(str), do: escape(inspect(str))

  @doc """
  Converts an hstore serialized string into an `Elixir Map`.
  """
  def load(hstore) when is_binary(hstore) do
    load(to_char_list(hstore))
  end
  def load(chars) when is_list(chars), do: load(chars, %{})
  def load(_), do: :error

  defp load([], acc), do: {:ok, acc}
  defp load([44,32|tail], acc), do: load(tail, acc)
  defp load(chars, acc) do
    {map, tail} = load_kvp(chars)
    load(tail, Map.merge(acc, map))
  end

  defp load_kvp(chars) do
    {key, [61,62|tail]} = read_item_quoted(chars)
    {value, tail} = read_item_quoted(tail)
    if !is_nil(value), do: value = to_string(value)
    {Dict.put(%{}, to_string(key), value), tail}
  end

  defp read_item_quoted([34|tail]), do: read_item_quoted(tail, [])
  defp read_item_quoted([78,85,76,76|tail]), do: {nil, tail}
  defp read_item_quoted([92,34|tail], acc), do: read_item_quoted(tail, [34|acc])
  defp read_item_quoted([34|tail],    acc), do: {Enum.reverse(acc), tail}
  defp read_item_quoted([ch|tail],    acc), do: read_item_quoted(tail, [ch|acc])
end
