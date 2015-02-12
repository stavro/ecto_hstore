defmodule HStorex do
  use ExUnit.Case, async: true
  import Postgrex.TestHelper
  alias Postgrex.Connection, as: P
  alias Postgrex.TypeInfo

  setup do
    {:ok, pid} = P.start_link(
      database: "postgrex_test",
      extensions: [{Hstorex.Hstore, {}}])
    {:ok, [pid: pid]}
  end

  test "encode and decode", context do
    assert [{%{"foo" => "bar"}}] = query("SELECT $1::hstore", [%{foo: "bar"}])
    assert [{%{"foo" => "bar"}}] = query("SELECT $1::hstore", [%{"foo": "bar"}])
    assert [{%{"foo" => "1", "bar" => "2"}}] = query("SELECT $1::hstore", [%{foo: 1, bar: 2}])
    assert [{%{"foo" => "1", "bar" => "2"}}] = query("SELECT $1::hstore", [%{foo: 1, bar: 2}])
    assert [{%{"foo" => nil}}] = query("SELECT $1::hstore", [%{foo: nil}])
    assert [{%{"foo bar" => nil}}] = query("SELECT $1::hstore", [%{"foo bar" => nil}])
    assert %Postgrex.Error{} = query("SELECT $1::hstore", [%{nil: "bar"}])
    assert [{%{"unicode\x{0065}\x{0301}" => "foo"}}] = query("SELECT $1::hstore", [%{"unicode\x{0065}\x{0301}" => "foo"}])
  end
end