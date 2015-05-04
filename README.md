Ecto.Hstore
===========

> Note: This package works with the current versions of Postgrex and Ecto.  However, upon the next major release of Postgrex, a more efficient Hstore decoder will be merged into the Postgrex core plugin, and this text-based parsing workaround will no longer be needed.

Ecto.Hstore adds Postgres Hstore compatibility to your Ecto models for storing sets of key/value pairs within a single PostgreSQL value.  This can be useful in various scenarios, such as rows with many attributes that are rarely examined, or semi-structured data. Keys and values are simply text strings.

Hstore structures are represented by Elixir Maps.

## Installation

Add Ecto.Hstore as a dependency in your `mix.exs` file.

```elixir
defp deps do
  [{:postgrex, ">= 0.0.0"},
   {:ecto, "~> 0.7"},
   {:ecto_hstore, "~> 0.0.1"}]
end
```

After you are done, run `mix deps.get` in your shell to fetch the dependencies.

## Usage

Enable Hstore through an ecto migration:

```elixir
defmodule Repo.Migrations.EnableHstore do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS hstore "
  end

  def down do
    execute "DROP EXTENSION IF EXISTS hstore "
  end
end
```

Add your desired Postgres hstore columns through a migration:

```elixir
defmodule Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table :users do
      add :flags, :hstore, null: false, default: ""
    end
  end

  def down do
    drop table(:users)
  end
end
```

Define your Ecto model's schema using the corresponding `Ecto.Hstore` type:

```elixir
defmodule User do
  use Ecto.Model

  schema "users" do
    field :flags, Ecto.Hstore
  end
end
```

And now you're all set!

```elixir
# Inserting a new user with flags is as simple as creating an Elixir Map:
user = Repo.insert %User{flags: %{key: "value"}}
user.flags #=> %{"key" => "value"}

# Updating the hstore value is as simple as `Dict.put`
flags = Dict.put(user.flags, "key2", "value2")
user = %User{user| flags: flags}
Repo.update user

query = from u in User,
          where: fragment("?->'?' = '?'", u.flags, "key2", "value2"),
          select: u

users = Repo.all(query) #=> [%User{flags: %{"key" => "value", "key2" => "value2"} ...]
```

## Quirks

Elixir Maps and Postgres Hstore types have a few important differences that users should be cautious of.  The current behavior of these edge cases may change in future releases of `Ecto.Hstore`.

  * Postgres Hstore does not allow `null` keys, whereas Elixir Maps do.  Currently `nil` keys will not be serialized to Postgres.
  * Postgres Hstore does not have an `atom` type.  All keys are stored as strings.  Therefore extra caution must be taken to ensure that an Elixir Map doesn't contain two converging keys (eg: `%{:a => 2, "a" => 2}`), because they will be consolidated to one string key `"a"` in a non-deterministic manner.
  * Postgres Hstore only supports a single level of key/value pairs.  Nested maps are not supported, and attempting to serialize nested maps will give undesirable results.

## Contributing

To contribute you need to compile Ecto.Hstore from source and test it:

```
$ git clone https://github.com/stavro/ecto_hstore.git
$ cd ecto_hstore
$ mix test
```

## License

Copyright 2015 Sean Stavropoulos

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
