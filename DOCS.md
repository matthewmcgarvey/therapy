# Therapy Docs

Therapy is a Crystal validation and parsing library inspired by Zod. It converts untyped input (JSON, hashes, form params) into strongly-typed Crystal NamedTuples with validation.

## Quick start

```crystal
schema = Therapy.object(
  name: Therapy.string.strip.min(1),
  age: Therapy.int.min(0),
  admin: Therapy.bool.optional,
)

result = schema.parse({"name" => "  Amy ", "age" => 32, "admin" => "true"})
if result.success?
  pp result.value # => {name: "Amy", age: 32, admin: true}
else
  pp result.errors
end
```

## Types

Each type documents what it can coerce, its validations, and transformations.

### StringType

Construct with `Therapy.string`.

- Coercion
  - Accepts `String` as-is.
  - Accepts `JSON::Any` and uses `value.raw` (must be a `String`).
- Validations
  - `min(size : Int32)` - minimum string length.
  - `max(size : Int32)` - maximum string length.
  - `size(size : Int32)` - exact string length.
  - `one_of(*options : String)` / `one_of(options : Array(String))` - must be one of the provided values.
  - `starts_with(prefix : String)` - must start with prefix.
  - `ends_with(suffix : String)` - must end with suffix.
  - `matches(regex : Regex)` - must match regex.
- Transformations
  - `strip` - trims leading/trailing whitespace before validations.

### IntType

Construct with `Therapy.int` (defaults to `Int32`) or `Therapy.int(Int64)` etc.

- Coercion
  - Accepts any `Int` and casts to the configured integer type.
  - Accepts `JSON::Any` and uses `value.raw` (must be an `Int`).
- Validations
  - `min(min : INT)` - minimum value.
  - `max(max : INT)` - maximum value.
- Transformations
  - None.

### FloatType

Construct with `Therapy.float` (defaults to `Float64`) or `Therapy.float(Float32)`.

- Coercion
  - Accepts any `Float` and casts to the configured float type.
  - Accepts `JSON::Any` and uses `value.raw` (must be a `Float`).
- Validations
  - None built-in.
- Transformations
  - None.

### BoolType

Construct with `Therapy.bool`.

- Coercion
  - Accepts `Bool` as-is.
  - Accepts `String` values "true" or "false" (case-insensitive).
  - Accepts `JSON::Any` and uses `value.raw` (must be `Bool` or a valid `String`).
- Validations
  - None built-in.
- Transformations
  - None.

### EnumType

Construct with `Therapy.enum(MyEnum)`.

- Coercion
  - Accepts `String` and uses `ENUM.parse`.
  - Accepts `Int` and uses `ENUM.from_value`.
  - Accepts `JSON::Any` and uses `value.raw` (must be `String` or `Int`).
- Validations
  - None built-in (parsing fails if not a valid enum value).
- Transformations
  - None.

### ArrayType

Construct with `Therapy.array(element_validator)`.

- Coercion
  - Accepts `Array` and parses each element with the element validator.
  - Accepts `JSON::Any` where `value.as_a?` succeeds.
- Validations
  - Element validations are applied after coercion for each element.
  - No array-size validations are built in.
- Transformations
  - None.

### TupleType

Construct with `Therapy.tuple(type_a, type_b, ...)`.

- Coercion
  - Accepts `Array` and parses each index with the matching validator.
  - Accepts `JSON::Any` where `value.as_a?` succeeds.
  - Fails early if the array size does not match the tuple length.
- Validations
  - Element validations are applied after coercion for each element.
  - Tuple size is validated during coercion.
- Transformations
  - None.

### ObjectType

Construct with `Therapy.object(**fields)` (e.g. `Therapy.object(name: Therapy.string, admin: Therapy.bool)`).

- Coercion
  - Accepts `Hash`, `NamedTuple`, `JSON::Any` (hash), and `URI::Params`.
  - Builds the output named tuple using `OUT.from(hash)`.
- Validations
  - Field validations run for each validator after coercion.
  - `validate(err_msg : String, path : Array(String | Int32)? = nil, &validation : OUT -> Bool)`
    allows object-level validations; optionally provide a path for the error.
- Transformations
  - None.

### HashType

Construct with `Therapy.hash(key_validator, value_validator)`.

- Coercion
  - Accepts `Hash` and `JSON::Any` (hash).
  - Accepts `URI::Params` and builds key/value pairs, deduplicating keys.
- Validations
  - Key and value validators are applied to each pair.
- Transformations
  - None.

### OptionalType

Construct with `Therapy.string.optional` or any type's `optional` method.

- Coercion
  - `Nil` parses as `nil` successfully.
  - For `JSON::Any`, `null` parses as `nil`.
  - Non-nil values are delegated to the inner validator.
- Validations
  - Inner validations run only when the value is non-nil.
- Transformations
  - None.

### UnionType

Construct with `left.or(right)` (e.g. `Therapy.string.or(Therapy.int)`).

- Coercion
  - Tries the left validator first; if it fails, tries the right validator.
  - If both fail, errors are combined.
- Validations
  - Validations run on whichever branch succeeds.
- Transformations
  - None.
  
Note: `UnionType` returns a fixed failure message per branch and combines errors when both fail.

## Base API

- `parse(input) : Result(T)` - returns `Success(T)` or `Failure(T)`.
- `parse!(input) : T` - raises an error if parsing fails, otherwise returns `T`.
- `optional` - wrap any validator into `OptionalType`.
- `or` - build `UnionType`.

## Errors and paths

Errors carry a path of `Array(String | Int32)` that points to the failing field/index.
Examples: `["users", 0, "email"]`, `["meta", "tags", 3]`.
