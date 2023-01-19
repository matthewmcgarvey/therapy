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

- Get ObjectType to extend BaseType
- Remove lift from BaseType
- Make ObjectType coercing work with JSON::Any and URI::Params and other stuff
- Get path working on the context
- Errors need to have the path
- Add array support
- Add validations to objects (confirmation == password)

## Contributing

1. Fork it (<https://github.com/matthewmcgarvey/therapy/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [matthewmcgarvey](https://github.com/matthewmcgarvey) - creator and maintainer
