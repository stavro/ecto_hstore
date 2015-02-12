defmodule Hstorex.Hstore do
  alias Postgrex.TypeInfo
  @behaviour Postgrex.Extension

  @moduledoc """
  Encoder, Decoder, and format specification to be used with Postgrex for HStore data types

      opts = [hostname: "localhost", username: "postgres", database: "postgrex_test",
              extensions: [{Hstorex.Hstore, {}}]]

      {:ok, pid} = Postgrex.Connection.start_link(opts)
      {:ok, #PID<0.115.0>}

      {:ok, _} = Postgrex.Connection.query(pid, "CREATE TABLE hstore_test (id int, flags hstore)", [])
      {:ok, %Postgrex.Result{columns: nil, command: :create_table, num_rows: 0, rows: nil}}
      
      {:ok, _} = Postgrex.Connection.query(pid, "INSERT INTO hstore_test VALUES ($1, $2)", [1, %{key: "value"}])
      {:ok, %Postgrex.Result{columns: nil, command: :insert, num_rows: 1, rows: nil}}
      
      Postgrex.Connection.query(pid, "SELECT * FROM hstore_test", [])
      {:ok, %Postgrex.Result{columns: ["id", "flags"], command: :select, num_rows: 1,
            rows: [{1, %{"key" => "value"}}]}}
  """

  def init(opts),
    do: opts

  def matching(opts),
    do: [type: "hstore"]

  def format(opts),
    do: :binary

  def encode(%TypeInfo{type: "hstore"}, map, _state, opts) do
    Hstorex.Encoder.encode(map)
  end

  def decode(%TypeInfo{type: "hstore"}, hstore, _state, opts) do
    Hstorex.Decoder.decode(hstore)
  end
end
