# Therapy

Get it? Therapy... validation... come on!

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     therapy:
       github: matthewmcgarvey/therapy
   ```

2. Run `shards install`

## Usage

```crystal
require "therapy"

sign_up_form = Therapy.object(
  email: Therapy.string,
  password: Therapy.string,
  confirm: Therapy.string
).validate("Confirm must match password", path: ["password"]) do |form|
  form[:password] == form[:confirm]
end

json = JSON.parse(request.body)
sign_up = sign_up_form.parse!(json) #=> NamedTuple(email: String, password: String, confirm: String)
```

See [DOCS.md](DOCS.md) for full type reference, coercions, and validations.

## Development

TODO: Write development instructions here

## TODO

- more validations/transformations

## Contributing

1. Fork it (<https://github.com/matthewmcgarvey/therapy/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [matthewmcgarvey](https://github.com/matthewmcgarvey) - creator and maintainer
