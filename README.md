Hstorex
===========

Hstorex adds Postgres Hstore compatibility to your Postgrex connection or storing sets of key/value pairs within a single PostgreSQL value.  This can be useful in various scenarios, such as rows with many attributes that are rarely examined, or semi-structured data. Keys and values are simply text strings.

Hstore structures are represented by Elixir Maps, and serialization uses Postgres' binary format.

## Installation

Add Hstorex as a dependency in your `mix.exs` file.

```elixir
defp deps do
  [{:postgrex, git: "https://github.com/ericmj/postgrex.git"},
   {:hstorex, git: "https://github.com/stavro/hstorex.git"}}]
end
```

After you are done, run `mix deps.get` in your shell to fetch the dependencies.

## Usage

Enable Hstore through an migration:

```sql
CREATE EXTENSION IF NOT EXISTS hstore;
```

Add Hstorex to your extensions list during your Postgrex connection initialization:

```elixir
{:ok, pid} = Postgrex.Connection.start_link(extensions: [{Hstorex.Hstore, {}}])
```

And now you're all set!

```elixir

```

## Quirks

Elixir Maps and Postgres Hstore types have a few important differences that users should be cautious of.  The current behavior of these edge cases may change in future releases of `Ecto.Hstore`.

  * Postgres Hstore does not allow `null` keys, whereas Elixir Maps do.  Currently `nil` keys will not be serialized to Postgres.
  * Postgres Hstore does not have an `atom` type.  All keys are stored as strings.  Therefore extra caution must be taken to ensure that an Elixir Map doesn't contain two converging keys (eg: `%{:a => 2, "a" => 2}`), because they will be consolidated to one string key `"a"` in a non-deterministic manner.
  * Postgres Hstore only supports a single level of key/value pairs.  Nested maps are not supported, and attempting to serialize nested maps will give undesirable results.

## Contributing

To contribute you need to compile Ecto.Hstore from source and test it:

```
$ git clone https://github.com/stavro/hstorex.git
$ cd hstorex
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
