# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Therapy is a Crystal validation and parsing library inspired by Zod. It converts untyped input (JSON, hashes, form params) into strongly-typed Crystal NamedTuples with validation.

## Commands

```bash
crystal spec                    # Run all tests
crystal spec spec/therapy/...   # Run specific test file
shards install                  # Install dependencies
```

## Architecture

**Parsing Pipeline:**
```
Input → BaseType.parse() → ParseContext → coerce() → apply_checks() → Result(T)
```

**Key Abstractions:**
- `BaseType<T>` - Abstract base for all validators, defines the parsing pipeline
- `Result<T>` - Either `Success<T>` or `Failure<T>` with errors array
- `ParseContext<T, V>` - Tracks parsing state (value, errors, path to field)
- `Check<T>` - Validation rule as a lambda

**Type Hierarchy:**
All validators inherit from `BaseType<T>`:
- `StringType`, `IntType<INT>`, `FloatType<FLOAT>`, `BoolType`, `EnumType<E>` - primitives
- `ArrayType<T>`, `ObjectType<VALIDATORS, OUT>`, `TupleType<VALIDATORS, OUT>` - collections
- `OptionalType<T>`, `UnionType<L, R>` - composition

**DSL Entry Points** (in `src/therapy.cr`):
```crystal
Therapy.string, Therapy.int, Therapy.float, Therapy.bool
Therapy.array(element_type), Therapy.object(**fields), Therapy.tuple(*types)
Therapy.enum(MyEnum)
```

**Method Naming:**
- `parse(input) → Result(T)` - public API
- `parse!(input) → T` - raises on error
- `_parse(context)` - protected, orchestrates coercion + checks
- `_coerce(value)` - protected, type conversion (overloaded per input type)

**Coercion Pattern:**
Each type implements `_coerce` overloads for: `JSON::Any`, `Hash`, `NamedTuple`, `URI::Params`, and primitives.

**Error Paths:**
Errors include path to failing field as `Array(String | Int32)` (e.g., `["users", 0, "email"]`).

## Testing

Tests use Crystal's spec framework with a custom `be_error` matcher:
```crystal
validation.parse(input).should be_error("Expected error message")
```

## Known Issues

- Union type validation loses context about which branch succeeded during coercion
- OptionalType has workarounds for type erasure issues with checks
- ParseContext + Result combination is redundant (noted for future refactor)
