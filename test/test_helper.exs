exclude = if System.get_env("PGVERSION") == "8.4" do
  [requires_notify_payload: true]
else
  []
end

version_exclusions = case System.get_env("PGVERSION") do
  v when is_binary(v) ->
    ["8.4", "9.0", "9.1", "9.2", "9.3", "9.4"]
    |> Enum.filter(fn x -> x > v end)
    |> Enum.map(&{:min_pg_version, &1})
  _ ->
    []
end

ExUnit.configure exclude: version_exclusions ++ exclude

ExUnit.start

run_cmd = fn cmd ->
  key = :ecto_setup_cmd_output
  Process.put(key, "")
  status = Mix.Shell.cmd(cmd, fn(data) ->
    current = Process.get(key)
    Process.put(key, current <> data)
  end)
  output = Process.get(key)
  Process.put(key, "")
  {status, output}
end

sql = """
CREATE EXTENSION IF NOT EXISTS hstore;
"""

cmds = [
  ~s(psql -U postgres -c "DROP DATABASE IF EXISTS postgrex_test;"),
  ~s(psql -U postgres -c "CREATE DATABASE postgrex_test TEMPLATE=template0 ENCODING='UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8';"),
  ~s(psql -U postgres -d postgrex_test -c "#{sql}")
]

Enum.each(cmds, fn cmd ->
  {status, output} = run_cmd.(cmd)

  if status != 0 do
    IO.puts """
    Command:
    #{cmd}
    error'd with:
    #{output}
    Please verify the user "postgres" exists and it has permissions to
    create databases and users. If not, you can create a new user with:
    $ createuser postgres -d -r --no-password
    """
    System.halt(1)
  end
end)

defmodule Postgrex.TestHelper do
  defmacro query(stat, params, opts \\ []) do
    quote do
      case Postgrex.Connection.query(var!(context)[:pid], unquote(stat),
                                     unquote(params), unquote(opts)) do
        {:ok, %Postgrex.Result{rows: nil}} -> :ok
        {:ok, %Postgrex.Result{rows: rows}} -> rows
        {:error, %Postgrex.Error{} = err} -> err
      end
    end
  end
end