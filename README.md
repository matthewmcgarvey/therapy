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
  email: Therapy.string.coercing,
  password: Therapy.string.coercing,
  confirm: Therapy.string.coercing
).coercing.validate("Confirm must match password") do |form|
  form[:password] == form[:confirm]
end

json = JSON.parse(request.body)
sign_up = sign_up_form.parse!(json) #=> NamedTuple(email: String, password: String, confirm: String)
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## TODO

- Support enums
- Cascade coercion so that you don't have to specify it on every attribute
  - This could be a bad idea
  - I want to be able to coerce json, not necessarily coerce ints to string
  - What I _really_ want is for json parsing to turn fields into the string value when the parent is coercing
  - this is probably why I originally had object pulling the raw value from JSON::Any when passing to coerce instead of passing the json
- Allow specifying the path on the object validation
  - When checking password confirmation, the path of the error should point towards it

## Contributing

1. Fork it (<https://github.com/matthewmcgarvey/therapy/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [matthewmcgarvey](https://github.com/matthewmcgarvey) - creator and maintainer
