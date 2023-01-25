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

therapy = Therapy.for(request.form)
email = therapy.parse_str("email").value
password = therapy.parse_str("password").value
therapy.parse_str("password_confirmation").eq(password_validation.value?).valid!
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## TODO

- Support enums
- Support tuples
  - I made arrays take in one validation and all items expected to conform that that
- Nested objects
- Arbitrary nesting
- Change how handling of json works
  - I don't remember why I decided that the base types wouldn't coerce JSON::Any themselves

## Contributing

1. Fork it (<https://github.com/matthewmcgarvey/therapy/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [matthewmcgarvey](https://github.com/matthewmcgarvey) - creator and maintainer
