# Notes

## 01-02-2026

3 years later...
I've fixed several bugs in the code but there's way more lurking, I just don't know about them yet and haven't written too many tests.
As I write more, the types become more and more convuluted and I've had to just remove return types and things because I cannot understand how to type it appropriately (see the OptionalType).
I did a terrible job with the `parse -> _parse -> coerce -> _do_coerce -> _coerce`. Who knows if that's even correct, but that is a crazy flow.
I think the idea is
- parse takes in a raw type and returns a result
- _parse takes in the parse context to run checks (which are validations or modifications (string's strip function)) & returns nothing
- coerce takes in the parse context and returns a new parse context that either successfully coerced the type or failed
- _do_coerce also takes in the parse context ?
- _coerce takes in the raw value and returns a result
So, writing that out, I think _do_coerce could be removed, but I'm not sure. They all need better names though.
Coming back, I still think this is my ideal way of parsing json or form input.
I looked at <https://github.com/qequ/schematics> but it can't handle required input without making the type optional.
One thing I might consider adding is a way to parse an object into a class instead of only working with named tuples.

## 01-24-2023

Just want to make anote that I'm trying to add ArrayType right now by referencing ObjectType and I'm
having a hard time understanding how ObjectType works 😂

## 01-19-2023

I really love what I've built so far with this very. The API is very clean.
The only thing I don't love right now is this "lifting" of single value validation/parsing
to combine them for objects. This is where this library will greatly differ from Zod
because not everything is a JSON object type thing. Rather than having to tell lower-level pieces how to
parse their input from the larger context, I'd rather the higher-level pieces know how to
pull from its context to hand to the lower-level. I think this will have to work with the "coercing"
concept. By default I guess the input will be expected to be a named tuple? If you enable coercing,
then it can use a hash, JSON, URI::Params.

Only downside of this that I can think of is that it's limited to what I can foresee being useful.
What if the user wants the input to be a class they defined? How do I make it flexible enough that
they can still instruct the library how to parse their data?

## 01-11-2023

Why not rewrite this library... AGAIN?!?!

I have never heard of [zod](https://zod.dev/) but apparently it's a big deal in the JS-world.
It also happens to be _exactly_ what I am wanting to build, so I'm wondering if it's possible to
have a similar API.

## 01-10-2023

I thought it would be a good idea to limit a Parser to have the error type of just a string,
but that breaks when I'm trying to zip together parsers. I need the errors to be separated.

## 01-06-2023

I don't understand how in the kotlin library, you can go from
`Parser<String?, String?, Nothing>` to `Parser<String?, String?, String>`.
I don't think it's possible to do in Crystal. it seems more like a failure of the
Kotlin type system than a feature. In crystal, you'd have to make the new parser have
an error type of the union of the new and old types.

As long as all methods have handling for failure, the only place that can't fail is
the beginning method `from_nilable_string` since it is just passing through whatever
it receives. I think I will make a Failable and Non-Failable version so that I don't
have to try to copy what looks like broken Kotlin.

## 01-03-2023

Finding inspiration in https://github.com/sksamuel/tribune

I originally considered going with Rust's style of request parsing,
but their community is centered around Serde which is agnostic serialization/deserialization.
Crystal doesn't have that so the API would be unnatural especially when it comes to 
things like JSON parsing.

I'll think I'll just go back to the parsing/validation of individual fields and then
adding in composability like I originally was trying to do.
