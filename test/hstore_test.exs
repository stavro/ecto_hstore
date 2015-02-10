defmodule Ecto.HstoreTest do
  use ExUnit.Case, async: true

  test "dump" do
    assert Ecto.Hstore.dump(%{a: 1}) == {:ok, ~s("a"=>"1")}
    assert Ecto.Hstore.dump(%{"a" => 1}) == {:ok, ~s("a"=>"1")}
    assert Ecto.Hstore.dump(%{a: "123,456"}) == {:ok, ~s("a"=>"123,456")}
    assert Ecto.Hstore.dump(%{key: nil}) == {:ok, ~s("key"=>NULL)}
    assert Ecto.Hstore.dump(%{a: 1, b: "2"}) == {:ok, ~s("a"=>"1", "b"=>"2")}
    assert Ecto.Hstore.dump(%{a: ~s("quote")}) == {:ok, ~s("a"=>"\\"quote\\"")}
    assert Ecto.Hstore.dump(%{"a b" => "cde"}) == {:ok, ~s("a b"=>"cde")}
    assert Ecto.Hstore.dump(%{a: "unicode\x{0065}\x{0301}"}) == {:ok, ~s("a"=>"unicode\x{0065}\x{0301}")}
    assert Ecto.Hstore.dump(%{nil: "value", a: 1}) == {:ok, ~s("a"=>"1")}
    assert Ecto.Hstore.dump(%{nil: "value"}) == {:ok, ~s()}
  end

  test "load" do
    assert Ecto.Hstore.load(~s("a"=>"1"))         == {:ok, %{"a" => "1"}}
    assert Ecto.Hstore.load(~s("a"=>"123,456"))   == {:ok, %{"a" => "123,456"}}
    assert Ecto.Hstore.load(~s("key"=>NULL))      == {:ok, %{"key" => nil}}
    assert Ecto.Hstore.load(~s("a"=>"1", "b"=>"2"))   == {:ok, %{"a" => "1", "b" => "2"}}
    assert Ecto.Hstore.load(~s("a"=>"\\"quote\\"")) == {:ok, %{"a" => ~s("quote")}}
    assert Ecto.Hstore.load(~s("a b"=>"cde")) == {:ok, %{"a b" => "cde"}}
    assert Ecto.Hstore.load(~s("a"=>"unicode\x{0065}\x{0301}")) == {:ok, %{"a" => "unicode\x{0065}\x{0301}"}}
    assert Ecto.Hstore.load(~s()) == {:ok, %{}}
  end
end
