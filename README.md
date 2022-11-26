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

sign_up_form_validation = Therapy.compose(
  Therapy.for(String?).presence("Email must be present").lift(URI::Params, &.[]?("email")),
  Therapy.for(String?).presence("Password must be present").lift(URI::Params, &.[]?("password")),
  Therapy.for(URI::Params).is_true("Password confirmation must match password") { |form| form["password_confirmation"]? == form["password"]? }
).transforming { |form| {email: form["email"], password: form["password"]} }

# Use the safe API to check on the results of the validation
validation = sign_up_form_validation.validate(form)
if validation.valid?
  data = validation.data
  ...
else
  puts validation.errors
end

# Use the unsafe API to get right to the data or raise an error
data = sign_up_form_validation.validate!(form)
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/matthewmcgarvey/therapy/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [matthewmcgarvey](https://github.com/matthewmcgarvey) - creator and maintainer
